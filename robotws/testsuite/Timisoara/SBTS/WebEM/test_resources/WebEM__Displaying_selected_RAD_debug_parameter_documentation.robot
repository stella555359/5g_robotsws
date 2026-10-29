*** Settings ***
Documentation
    ...  This TC is created to verify R&D debug parameters.
    ...  Verify if reload domains is possible.
    ...  Verify if domains appeared.
    ...  If at least one parameter is changed, reload all domains is performed.
    ...  Select OamUri domain and verify if all parameters are visible.
    ...  For each paramters verify documentation.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__Displaying_selected_RAD_debug_parameter_documentation
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24459
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 17.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24459 - Initial TAT creation
    ...  - 10.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28735 - New description for troubleshooting parameter and RF5.0 KWs replacement

    Set Tags  CA-WebEM  OWNER-cristina.antoci@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS23  FEATURE-CB007041

    Step1: Verify If R&D SW Domains Are Available
    Step2: Select OamUri Domain And Verify All Parameters
    Step3: Verify Documentation For All OamUri Parameters


Step1: Verify If R&D SW Domains Are Available
    Log  \nStep1: Get R&D SW domain  console=true
    Open BTS R&D Debug Parameters Management
    Wait Until Element Is Visible  //*[contains(text(), "Please select a domain from list to get its parameters.")]  120
    Log  Reload domains will be performed!  console=true
    Wait Until Element Is Clicked  //*[contains(@label, "Reload Domains")]  120
    ${div_number}  Set Variable If  '${GUI_VERSION}' == 'new'  2  3
    Wait Until Element Is Clicked  xpath:/html/body/div[${div_number}]/div/div[3]/ot-footer/p-button[1]/button  120
    Wait Until Element Is Visible  //*[contains(text(), "Reload domains completed")]  300
    Log  Reload domains completed!  console=true
    Wait Until Element Is Visible  //*[contains(text(), "Please select a domain from list to get its parameters.")]  120
    ${domains}  SeleniumLibrary.Get Element Count  //*[@class="p-listbox-list-wrapper"]/ul/li
    IF  ${domains} > 0
        Log  Domanins are available![OK]  console=true
        ELSE
        Fail  Domains are not available![NOK]
    END
    Wait Until Element Is Clicked  //*[contains(@class, "bts-rd-parameter-management ng-scope")]/p-tabview/div/div[1]/div/ul/li[2]  120
    ${status}  Run Keyword And Return Status
    ...  Wait Until Element Is Visible  //*[contains(text(), "No data")]  120
    IF  ${status}
        Wait Until Element Is Clicked  //*[contains(@class, "bts-rd-parameter-management ng-scope")]/p-tabview/div/div[1]/div/ul/li[1]  120
        RETURN
    END
    Wait Until Element Is Clicked  //*[contains(@class, 'p-button-label ng-star-inserted') and contains(text(), 'Restore All to Defaults')]  120
    Wait Until Element Is Clicked  xpath:/html/body/div[${div_number}]/div/div[3]/ot-footer/p-button[1]  120
    Wait Until Element Is Visible  //*[contains(text(), "Restore success, fetch non-default R&D debug parameters success")]  300
    Wait Until Element Is Clicked  //*[contains(@class, "bts-rd-parameter-management ng-scope")]/p-tabview/div/div[1]/div/ul/li[1]  120


Step2: Select OamUri Domain And Verify All Parameters
    Log  Step2: Select OamUri domain and verify all parameters  console=true
    Wait Until Element Is Visible  //*[contains(@aria-label, 'OamUri')]  120
    Click Element  xpath=//*[contains(@aria-label, 'OamUri')]
    Wait Until Element Is Visible  //*[contains(text(), "Current value")]  120
    ${number_of_parameters}  SeleniumLibrary.Get Element Count  xpath=//table[@class="p-datatable-table ng-star-inserted"]/tbody/tr
    Set Test Variable  ${NUMBER_OF_PARAMETERS}
    ${parameters_name_list}  Create List
    FOR  ${parameter}  IN RANGE  1  ${NUMBER_OF_PARAMETERS}+1
        ${parameter_name}  Get Text  xpath=//table[@class="p-datatable-table ng-star-inserted"]/tbody/tr[${parameter}]/td[2]
        ${parameter_value}  Get Text  xpath=//table[@class="p-datatable-table ng-star-inserted"]/tbody/tr[${parameter}]/td[3]
        Should Be Equal  ${parameter_value}  false
        Log  Parameter ${parameter_name} is visible and the value is false![OK]  console=true
        Append To List  ${parameters_name_list}  ${parameter_name}
    END
    Set Test Variable  ${PARAMETERS_NAME_LIST}


Step3: Verify Documentation For All OamUri Parameters
    Log  Step3: Verify documentation for all OamUri parameters  console=true
    Wait Until Element Is Clicked  //*[contains(@class, 'details-panel-container')]/ui-button/button/i  120
    FOR  ${parameter}  IN RANGE  0  ${NUMBER_OF_PARAMETERS}
        Click Element  xpath=//table[@class="p-datatable-table ng-star-inserted"]/tbody/tr[${parameter+1}]/td[2]
        ${parameter_details_name}  Get Text  xpath=//table[@class="details-info-table"]/tr[1]/td[2]
        Should Be Equal  ${parameter_details_name}  ${PARAMETERS_NAME_LIST}[${parameter}]
        ${parameter_details_domain}  Get Text  xpath=//table[@class="details-info-table"]/tr[2]/td[2]
        Should Be Equal  ${parameter_details_domain}  OamUri
        ${parameter_details_performance}  Get Text  xpath=//table[@class="details-info-table"]/tr[3]/td[2]
        Should Be Equal  ${parameter_details_performance}  none
        ${parameter_details_hardware}  Get Text  xpath=//table[@class="details-info-table"]/tr[4]/td[2]
        Should Be Equal  ${parameter_details_hardware}  -
        ${parameter_details_description}  Get Text  xpath=//table[@class="details-info-table"]/tr[5]/td[2]
        ${short_name}  Fetch From Right  ${PARAMETERS_NAME_LIST}[${parameter}]  Print
        IF  '${parameter_details_name}' == 'PrintTroubleshooting'
            Should Be Equal  ${parameter_details_description}  Print flag with ${short_name}  ignore_case=true
            ELSE
            Should Be Equal  ${parameter_details_description}  Print flag with URI/${short_name}  ignore_case=true
        END
        ${parameter_details_default_value}  Get Text  xpath=//table[@class="details-info-table"]/tr[6]/td[2]
        Should Be Equal  ${parameter_details_default_value}  false
        ${parameter_details_allowed_values}  Get Text  xpath=//table[@class="details-info-table"]/tr[7]/td[2]
        Should Be Equal  ${parameter_details_allowed_values}  false, true
        Log  Documentation is visible and correct for ${PARAMETERS_NAME_LIST}[${parameter}] parameter![OK]  console=true
    END


TC Setup
    Common Test Setup
    WebEM Setup


TC Teardown
    WebEM Teardown
    Common Test Teardown
