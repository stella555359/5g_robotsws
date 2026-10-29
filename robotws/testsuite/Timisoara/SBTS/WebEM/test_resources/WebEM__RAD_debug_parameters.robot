*** Settings ***
Documentation
    ...  This TC is created to verify R&D debug parameters.
    ...  Verify if reload domains is possible.
    ...  Verify if domains appeared.
    ...  If at least one parameter is changed, reload all domains is performed.
    ...  Changing and verify parameters from Legacy(2 parameters), Oam(1), LteCellP(all), 5GCPRT(1) for not persistent, one reset and persistent.
    ...  For not persistent, after one reset site the parameters should have default values.
    ...  For one reset, after two reset site the parameters should have default values.
    ...  For persistent, after three reset site the parameters should haven't default values.
    ...  Restore each parameters to have default value.
    ...  Changing again all parameters from all specific domains.
    ...  Verify if domains apeard in Non-default R&D Debug Parameters.
    ...  Verify if the specific icon is appeared.
    ...  Reload all domains from this menu.
    ...  Verify if the specific icon is disappeared.
    ...  Filtering domains in BTS R&D Debug Parameters.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}  1200  # Timeout for SBTS to recover
${RESTORE_TIMEOUT}  60s  # Timeout for parameter to be restored


*** Keywords ***
TC__WebEM__RAD_debug_parameters
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24386
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 31.01.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24386 - Initial TAT creation
    ...  - 22.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26695 - Change value of parameter from 5GCPRT domain in trunk SW
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring
    ...  - 08.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27457 - Change xpath for non-default button
    ...  - 24.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29095 - Change table class for trunk
    ...  - 21.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30028 - Change many xpaths for trunk

    Set Tags  CA-WebEM  OWNER-nicolae-marcel.caragel@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS23

    Step1: Get R&D SW Domain
    Step2: Selecting Domains And Change Parameters For Not Persistent
    Step3: Selecting Domains And Change Parameters For One-reset
    Step4: Selecting Domains And Change Parameters For Persistent
    Step5: Restore All Parameters From BTS R&D Debug Parameters
    Step6: Verify Domains And Parameters In Non-default R&D Debug Parameters
    Step7: Filtering Domains In BTS R&D Debug Parameters


Step1: Get R&D SW Domain
    Log  \nStep1: Get R&D SW domain  console=true
    Open BTS R&D Debug Parameters Management
    Wait Until Element Is Visible  //*[contains(text(), "Please select a domain from list to get its parameters.")]  120
    Log  Reload domains will be performed!  console=true
    Wait Until Element Is Clicked  //*[contains(@label, "Reload Domains")]  120
    ${DIV_NUMBER}  Set Variable If  '${GUI_VERSION}' == 'new'  2  3
    Set Test Variable  ${DIV_NUMBER}
    Wait Until Element Is Clicked  xpath:/html/body/div[${DIV_NUMBER}]/div/div[3]/ot-footer/p-button[1]/button  120
    Wait Until Element Is Visible  //*[contains(text(), "Reload domains completed")]  300
    Log  Reload domains completed!  console=true
    Wait Until Element Is Visible  //*[contains(text(), "Please select a domain from list to get its parameters.")]  120
    ${domains}  SeleniumLibrary.Get Element Count  //*[@class="p-listbox-list-wrapper"]/ul/li
    IF  ${domains} > 0
        Log  Domanins are available![OK]  console=true
    ELSE
        Fail  Domains are not available![NOK]
    END
    Set Test Variable  ${NON_DEFAULT_BUTTON}  //*[contains(@class, "bts-rd-parameter-management ng-scope")]/p-tabview/div/div[1]/div/ul/li[2]
    Wait Until Element Is Clicked  ${NON_DEFAULT_BUTTON}  120
    ${status}  Run Keyword And Return Status
    ...  Wait Until Element Is Visible  //*[contains(text(), "No data")]  120
    IF  ${status}
        Wait Until Element Is Clicked  //*[contains(@class, "bts-rd-parameter-management ng-scope")]/p-tabview/div/div[1]/div/ul/li[1]  120
        RETURN
    END
    Wait Until Element Is Clicked  //*[contains(@class, 'p-button-label ng-star-inserted') and contains(text(), 'Restore All to Defaults')]  120
    Wait Until Element Is Clicked  xpath:/html/body/div[${DIV_NUMBER}]/div/div[3]/ot-footer/p-button[1]  120
    Wait Until Element Is Visible  //*[contains(text(), "Restore success, fetch non-default R&D debug parameters success")]  300


Step2: Selecting Domains And Change Parameters For Not Persistent
    Log  \nStep2: Selecting domains and change parameters for not persistent  console=true
    Set Test Variable  ${BTS_RAD_BUTTON}  //*[contains(@class, "bts-rd-parameter-management ng-scope")]/p-tabview/div/div[1]/div/ul/li[1]
    IF  '${ENB_BRANCH}' >= 'SBTS25R3'
        Set Test Variable  ${TABLE_CLASS}  //table[contains(@class, 'p-datatable-table w-full ng-star-inserted')]
    ELSE
        Set Test Variable  ${TABLE_CLASS}  //table[@class="p-datatable-table ng-star-inserted"]
    END
    Wait Until Element Is Clicked  ${BTS_RAD_BUTTON}  120
    Verify Parameters From Legacy Domain  true  0
    Verify Parameters From Oam Domain  1 - enabled
    IF  ${SCF_COUNT_LTE}  Verify Parameters From LteCellP Domain  false
    IF  ${SCF_COUNT_NR} and '${ENB_BRANCH}' >= 'SBTS24R2'
        Verify Parameters From 5GCPRT Domain  30
    ELSE IF  ${SCF_COUNT_NR} and '${ENB_BRANCH}' < 'SBTS24R2'
        Verify Parameters From 5GCPRT Domain  0
    END
    Change Parameters From Legacy Domain
    Apply Changes And Choose The Specific Persistency  Not persistent
    Change Parameter From Oam Domain
    Apply Changes And Choose The Specific Persistency  Not persistent
    IF  ${SCF_COUNT_LTE}
        Change Parameters From LteCellP Domain
        Apply Changes And Choose The Specific Persistency  Not persistent
    END
    IF  ${SCF_COUNT_NR}
        Change Parameter From 5GCPRT Domain
        Apply Changes And Choose The Specific Persistency  Not persistent
    END
    Wait Until Keyword Succeeds  120  5
    ...  Go To Site View
    Reset SBTS From Admin
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells
    Open BTS R&D Debug Parameters Management
    Verify Parameters From Legacy Domain  true  0
    Verify Parameters From Oam Domain  1 - enabled
    IF  ${SCF_COUNT_LTE}  Verify Parameters From LteCellP Domain  false
    IF  ${SCF_COUNT_NR} and '${ENB_BRANCH}' >= 'SBTS24R2'
        Verify Parameters From 5GCPRT Domain  30
    ELSE IF  ${SCF_COUNT_NR} and '${ENB_BRANCH}' < 'SBTS24R2'
        Verify Parameters From 5GCPRT Domain  0
    END


Step3: Selecting Domains And Change Parameters For One-reset
    Log  \nStep3: Selecting domains and change parameters for one-reset  console=true
    ${first_value}  Change Parameters From Legacy Domain
    Apply Changes And Choose The Specific Persistency  One reset
    Change Parameter From Oam Domain
    Apply Changes And Choose The Specific Persistency  One reset
    IF  ${SCF_COUNT_LTE}
        Change Parameters From LteCellP Domain
        Apply Changes And Choose The Specific Persistency  One reset
    END
    ${second_value}  IF  ${SCF_COUNT_NR}  Change Parameter From 5GCPRT Domain
    IF  ${SCF_COUNT_NR}  Apply Changes And Choose The Specific Persistency  One reset
    Wait Until Keyword Succeeds  120  5
    ...  Go To Site View
    Reset SBTS From Admin
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells
    Open BTS R&D Debug Parameters Management
    Verify Parameters From Legacy Domain  false  ${first_value}
    Verify Parameters From Oam Domain  0 - disabled
    IF  ${SCF_COUNT_LTE}  Verify Parameters From LteCellP Domain  true
    IF  ${SCF_COUNT_NR}  Verify Parameters From 5GCPRT Domain  ${second_value}
    Wait Until Keyword Succeeds  120  5
    ...  Go To Site View
    Reset SBTS From Admin
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells
    Open BTS R&D Debug Parameters Management
    Verify Parameters From Legacy Domain  true  0
    Verify Parameters From Oam Domain  1 - enabled
    IF  ${SCF_COUNT_LTE}  Verify Parameters From LteCellP Domain  false
    IF  ${SCF_COUNT_NR} and '${ENB_BRANCH}' >= 'SBTS24R2'
        Verify Parameters From 5GCPRT Domain  30
    ELSE IF  ${SCF_COUNT_NR} and '${ENB_BRANCH}' < 'SBTS24R2'
        Verify Parameters From 5GCPRT Domain  0
    END


Step4: Selecting Domains And Change Parameters For Persistent
    Log  \nStep4: Selecting domains and change parameters for persistent  console=true
    ${first_value}  Change Parameters From Legacy Domain
    Apply Changes And Choose The Specific Persistency  Persistent
    Change Parameter From Oam Domain
    Apply Changes And Choose The Specific Persistency  Persistent
    IF  ${SCF_COUNT_LTE}
        Change Parameters From LteCellP Domain
        Apply Changes And Choose The Specific Persistency  Persistent
    END
    ${second_value}  IF  ${SCF_COUNT_NR}  Change Parameter From 5GCPRT Domain
    IF  ${SCF_COUNT_NR}  Apply Changes And Choose The Specific Persistency  Persistent
    FOR  ${index}  IN RANGE  1  4
        Wait Until Keyword Succeeds  120  5
        ...  Go To Site View
        Reset SBTS From Admin
        Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
        ...  Check All Cells
        Open BTS R&D Debug Parameters Management
        Verify Parameters From Legacy Domain  false  ${first_value}
        Verify Parameters From Oam Domain  0 - disabled
        IF  ${SCF_COUNT_LTE}  Verify Parameters From LteCellP Domain  true
        IF  ${SCF_COUNT_NR}  Verify Parameters From 5GCPRT Domain  ${second_value}
    END


Step5: Restore All Parameters From BTS R&D Debug Parameters
    Log  \nStep5: Restore all parameters from BTS R&D Debug Parameters  console=true
    Restore Parameters From Legacy Domain
    Restore Parameters From Oam Domain
    IF  ${SCF_COUNT_LTE}  Restore Parameters From LteCellP Domain
    IF  ${SCF_COUNT_NR}  Restore Parameters From 5GCPRT Domain
    Verify Parameters From Legacy Domain  true  0
    Verify Parameters From Oam Domain  1 - enabled
    IF  ${SCF_COUNT_LTE}  Verify Parameters From LteCellP Domain  false
    IF  ${SCF_COUNT_NR} and '${ENB_BRANCH}' >= 'SBTS24R2'
        Verify Parameters From 5GCPRT Domain  30
    ELSE IF  ${SCF_COUNT_NR} and '${ENB_BRANCH}' < 'SBTS24R2'
        Verify Parameters From 5GCPRT Domain  0
    END


Step6: Verify Domains And Parameters In Non-default R&D Debug Parameters
    Log  \nStep6: Verify domains and parameters in Non-default R&D Debug Parameters  console=true
    Change Parameters From Legacy Domain
    Apply Changes And Choose The Specific Persistency  Not persistent
    Change Parameter From Oam Domain
    Apply Changes And Choose The Specific Persistency  Not persistent
    IF  ${SCF_COUNT_LTE}
        Change Parameters From LteCellP Domain
        Apply Changes And Choose The Specific Persistency  Not persistent
    END
    IF  ${SCF_COUNT_NR}
        Change Parameter From 5GCPRT Domain
        Apply Changes And Choose The Specific Persistency  Not persistent
    END
    Wait Until Element Is Clicked  ${NON_DEFAULT_BUTTON}  120
    Wait Until Element Is Visible  //table[@class="p-datatable-table ng-star-inserted"]/tbody/tr  120
    ${parameters_count}  SeleniumLibrary.Get Element Count  //table[@class="p-datatable-table ng-star-inserted"]/tbody/tr
    FOR  ${index}  IN RANGE  1  ${parameters_count}+1
        ${parameter_name}  Get Text  //table[@class="p-datatable-table ng-star-inserted"]/tbody/tr[${index}]/td[1]
        ${status}  Run Keyword And Return Status
        ...  Should Match Regexp  ${parameter_name}  Legacy|Oam|LteCellP|5GCPRT
        IF  ${status}  Log  Parameter from ${parameter_name} domain is visible in Non-Default R&D Debug Parameters![OK]  console=true
    END
    ${status}  Run Keyword And Return Status
    ...  Wait Until Element Is Visible  ${RAD_ICON}  60
    IF  ${status}
        Log  'At least one R&D debug parameter is set to non-default value' icon is visible![OK]  console=true
    ELSE
        Fail  'At least one R&D debug parameter is set to non-default value' icon is not visible![NOK]
    END
    Log  Restore all parameters to default will be performed!  console=true
    Wait Until Element Is Clicked  //*[contains(@class, 'p-button-label ng-star-inserted') and contains(text(), 'Restore All to Defaults')]  120
    Wait Until Element Is Clicked  xpath:/html/body/div[${DIV_NUMBER}]/div/div[3]/ot-footer/p-button[1]  120
    Wait Until Element Is Visible  //*[contains(text(), "Restore success, fetch non-default R&D debug parameters success")]  300
    Log  "Restore success, fetch non-default R&D debug parameters success" text appeared![OK]  console=true
    ${status}  Run Keyword And Return Status
    ...  Wait Until Element Is Visible  ${RAD_ICON}  20
    IF  ${status}
        Fail  'At least one R&D debug parameter is set to non-default value' icon is visible![NOK]
    ELSE
        Log  'At least one R&D debug parameter is set to non-default value' icon is not visible![OK]  console=true
    END


Step7: Filtering Domains In BTS R&D Debug Parameters
    Log  \nStep7: Filtering domains in BTS R&D Debug Parameters  console=true
    Wait Until Element Is Clicked  ${BTS_RAD_BUTTON}  120
    Log  Filtering domains by the word 'Oam'  console=true
    Wait Until Keyword Succeeds  300  5
    ...  Input Text  //*[contains(@class, 'p-listbox-filter p-inputtext p-component')]  oam
    Sleep  10s  Timeout for elements to be updated.
    ${oam_domains}  SeleniumLibrary.Get Element Count  //*[@class="p-listbox-list-wrapper"]/ul/li
    FOR  ${domain}  IN RANGE  1  ${oam_domains}+1
        ${domain_name}  Get Text  //*[@class="p-listbox-list-wrapper"]/ul/li[${domain}]
        ${status}  Run Keyword And Return Status
        ...  Should Contain  ${domain_name}  Oam
        IF  ${status}
            Log  Domanin ${domain_name} contain 'Oam'![OK]  console=true
        ELSE
            Fail  Domanin ${domain_name} does not contain 'Oam'![NOK]
        END
    END
    Log  Filtering was done successfully!  console=true


Change Parameters From Legacy Domain
    Log  Changing two parameters from Legacy domain!  console=true
    Wait Until Element Is Visible  //*[contains(@aria-label, 'Legacy')]  120
    Wait Until Element Is Clicked  xpath=//*[contains(@aria-label, 'Legacy')]
    Wait Until Element Is Visible  //*[contains(text(), "Current value")]  120
    ${parameter_name}  Get Text  ${TABLE_CLASS}/tbody/tr[3]/td[2]
    Log  Changing the value for parameter ${parameter_name} to be false...  console=true
    IF  '${ENB_BRANCH}' >= 'SBTS26R1'
        Wait Until Element Is Clicked  xpath=${TABLE_CLASS}/tbody/tr[3]/td[3]/p-dropdown/div
    ELSE
        Wait Until Element Is Clicked  xpath=${TABLE_CLASS}/tbody/tr[3]/td[3]/div/div/p-dropdown
    END
    Wait Until Element Is Visible  //*[contains(@aria-label, 'false')]  120
    Wait Until Element Is Clicked  xpath=//*[contains(@aria-label, 'false')]
    Log  The value is false![OK]  console=true
    ${parameter_name}  Get Text  ${TABLE_CLASS}/tbody/tr[4]/td[2]
    ${value}  Evaluate  random.randint(1,10)  random
    Log  Changing the value for parameter ${parameter_name} to be ${value}...  console=true
    IF  '${ENB_BRANCH}' >= 'SBTS26R1'
        Input Text  ${TABLE_CLASS}/tbody/tr[4]/td[3]/div/input  ${value}
    ELSE
        Input Text  ${TABLE_CLASS}/tbody/tr[4]/td[3]/div/div/div/input  ${value}
    END
    Log  The value is ${value}![OK]  console=true

    RETURN  ${value}


Change Parameters From LteCellP Domain
    Log  Change parameters from LteCellP domain!  console=true
    Wait Until Element Is Visible  //*[contains(@aria-label, 'LteCellP')]  120
    Wait Until Element Is Clicked  xpath=//*[contains(@aria-label, 'LteCellP')]
    Wait Until Element Is Visible  //*[contains(text(), "Current value")]  120
    ${parameters_count}  SeleniumLibrary.Get Element Count  ${TABLE_CLASS}/tbody/tr
    FOR  ${index}  IN RANGE  1  ${parameters_count}+1
        ${parameter_name}  Get Text  ${TABLE_CLASS}/tbody/tr[${index}]/td[2]
        Log  Changing the value for parameter ${parameter_name} to be true...  console=true
        IF  '${ENB_BRANCH}' >= 'SBTS26R1'
            Wait Until Element Is Clicked  xpath=${TABLE_CLASS}/tbody/tr[${index}]/td[3]/p-dropdown/div
        ELSE
            Wait Until Element Is Clicked  xpath=${TABLE_CLASS}/tbody/tr[${index}]/td[3]/div/div/p-dropdown
        END
        Wait Until Element Is Visible  //*[contains(@aria-label, 'true')]  120
        Wait Until Element Is Clicked  xpath=//*[contains(@aria-label, 'true')]
        Log  The value is true![OK]  console=true
    END


Change Parameter From Oam Domain
    Log  Change parameter from Oam domain!  console=true
    Wait Until Element Is Visible  //*[contains(@aria-label, 'Oam')]  120
    Wait Until Element Is Clicked  xpath=//*[contains(@aria-label, 'Oam')]
    Wait Until Element Is Visible  //*[contains(text(), "Current value")]  120
    ${parameter_name}  Get Text  ${TABLE_CLASS}/tbody/tr/td[2]
    Log  Changing the value for parameter ${parameter_name} to be 0 - disabled...  console=true
    IF  '${ENB_BRANCH}' >= 'SBTS26R1'
        Wait Until Element Is Clicked  xpath=${TABLE_CLASS}/tbody/tr/td[3]/p-dropdown/div
    ELSE
        Wait Until Element Is Clicked  xpath=${TABLE_CLASS}/tbody/tr/td[3]/div/div/p-dropdown
    END
    Wait Until Element Is Visible  //*[contains(@aria-label, '0 - disabled')]  120
    Wait Until Element Is Clicked  xpath=//*[contains(@aria-label, '0 - disabled')]
    Log  The value is 0 - disabled![OK]  console=true


Change Parameter From 5GCPRT Domain
    Log  Change parameter from 5GCPRT domain!  console=true
    Wait Until Element Is Visible  //*[contains(@aria-label, '5GCPRT')]  120
    Wait Until Element Is Clicked  xpath=//*[contains(@aria-label, '5GCPRT')]
    Wait Until Element Is Visible  //*[contains(text(), "Current value")]  120
    ${parameter_name}  Get Text  ${TABLE_CLASS}/tbody/tr[4]/td[2]
    ${value}  Evaluate  random.randint(1,60)  random
    Log  Changing the value for parameter ${parameter_name} to be ${value}...  console=true
    IF  '${ENB_BRANCH}' >= 'SBTS26R1'
        Input Text  ${TABLE_CLASS}/tbody/tr[4]/td[3]/div/input  ${value}
    ELSE
        Input Text  ${TABLE_CLASS}/tbody/tr[4]/td[3]/div/div/div/input  ${value}
    END
    Log  The value is ${value}![OK]  console=true

    RETURN  ${value}


Verify Parameters From Legacy Domain
    [Arguments]  ${first_parameter_value}  ${second_parameter_value}

    Log  Verify parameters from Legacy domain  console=true
    Wait Until Element Is Visible  //*[contains(@aria-label, 'Legacy')]  120
    Wait Until Element Is Clicked  xpath=//*[contains(@aria-label, 'Legacy')]
    Wait Until Element Is Visible  //*[contains(text(), "Current value")]  120
    ${parameter_name}  Get Text  ${TABLE_CLASS}/tbody/tr[3]/td[2]
    ${parameter_value}  Get Text  ${TABLE_CLASS}/tbody/tr[3]/td[3]
    Should Be Equal  ${parameter_value}  ${first_parameter_value}
    Log  Parameter ${parameter_name} is ${parameter_value}! [OK]  console=true
    ${parameter_name}  Get Text  ${TABLE_CLASS}/tbody/tr[4]/td[2]
    IF  '${ENB_BRANCH}' >= 'SBTS26R1'
        ${parameter_value}  Get Value  ${TABLE_CLASS}/tbody/tr[4]/td[3]/div/input
    ELSE
        ${parameter_value}  Get Value  ${TABLE_CLASS}/tbody/tr[4]/td[3]/div/div/div/input
    END
    ${parameter_value}  Convert To Integer  ${parameter_value}
    ${second_parameter_value}  Convert To Integer  ${second_parameter_value}
    Should Be Equal  ${parameter_value}  ${second_parameter_value}
    Log  Parameter ${parameter_name} is ${parameter_value}! [OK]  console=true


Verify Parameters From Oam Domain
    [Arguments]  ${value}

    Log  Verify parameters from Oam domain  console=true
    Wait Until Element Is Visible  //*[contains(@aria-label, 'Oam')]  120
    Wait Until Element Is Clicked  xpath=//*[contains(@aria-label, 'Oam')]
    Wait Until Element Is Visible  //*[contains(text(), "Current value")]  120
    ${parameter_name}  Get Text  ${TABLE_CLASS}/tbody/tr/td[2]
    ${parameter_value}  Get Text  ${TABLE_CLASS}/tbody/tr/td[3]
    Should Be Equal  ${parameter_value}  ${value}
    Log  Parameter ${parameter_name} is ${parameter_value}! [OK]  console=true


Verify Parameters From LteCellP Domain
    [Arguments]  ${value}

    Log  Verify parameters from LteCellP domain  console=true
    Wait Until Element Is Visible  //*[contains(@aria-label, 'LteCellP')]  120
    Wait Until Element Is Clicked  xpath=//*[contains(@aria-label, 'LteCellP')]
    Wait Until Element Is Visible  //*[contains(text(), "Current value")]  120
    ${parameters_count}  SeleniumLibrary.Get Element Count  ${TABLE_CLASS}/tbody/tr
    FOR  ${index}  IN RANGE  1  ${parameters_count}+1
        ${parameter_name}  Get Text  ${TABLE_CLASS}/tbody/tr[${index}]/td[2]
        ${parameter_value}  Get Text  ${TABLE_CLASS}/tbody/tr[${index}]/td[3]
        Should Be Equal  ${parameter_value}  ${value}
        Log  Parameter ${parameter_name} is ${parameter_value}! [OK]  console=true
    END


Verify Parameters From 5GCPRT Domain
    [Arguments]  ${value}

    Log  Verify parameters from 5GCPRT domain  console=true
    Wait Until Element Is Visible  //*[contains(@aria-label, '5GCPRT')]  120
    Wait Until Element Is Clicked  xpath=//*[contains(@aria-label, '5GCPRT')]
    Wait Until Element Is Visible  //*[contains(text(), "Current value")]  120
    ${parameter_name}  Get Text  ${TABLE_CLASS}/tbody/tr[4]/td[2]
    IF  '${ENB_BRANCH}' >= 'SBTS26R1'
        ${parameter_value}  Get Value  ${TABLE_CLASS}/tbody/tr[4]/td[3]/div/input
    ELSE
        ${parameter_value}  Get Value  ${TABLE_CLASS}/tbody/tr[4]/td[3]/div/div/div/input
    END
    ${parameter_value}  Convert To Integer  ${parameter_value}
    ${value}  Convert To Integer  ${value}
    Should Be Equal  ${parameter_value}  ${value}
    Log  Parameter ${parameter_name} is ${parameter_value}! [OK]  console=true


Restore Parameters From Legacy Domain
    Log  Restore parameters from Legacy domain  console=true
    Wait Until Element Is Visible  //*[contains(@aria-label, 'Legacy')]  120
    Wait Until Element Is Clicked  xpath=//*[contains(@aria-label, 'Legacy')]
    Wait Until Element Is Visible  //*[contains(text(), "Current value")]  120
    Wait Until Element Is Clicked  ${TABLE_CLASS}/tbody/tr[3]/td[4]/div/p-button  120
    Wait Until Element Is Clicked  xpath:/html/body/div[${DIV_NUMBER}]/div/div[3]/ot-footer/p-button[1]/button  120
    Sleep  ${RESTORE_TIMEOUT}  Timeout for parameter to be restored!
    ${parameter_name}  Get Text  ${TABLE_CLASS}/tbody/tr[3]/td[2]
    ${value}  Get Text  ${TABLE_CLASS}/tbody/tr[3]/td[4]/div/ot-instruction/div
    IF  '${value}'=='Succeeded'
        Log  Parameter ${parameter_name} is restored ${value}! [OK]  console=true
    ELSE
        Fail  Restore status for parameter ${parameter_name} is ${value}! [NOK]
    END
    ${parameter_name}  Get Text  ${TABLE_CLASS}/tbody/tr[4]/td[2]
    Wait Until Element Is Clicked  ${TABLE_CLASS}/tbody/tr[4]/td[4]/div/p-button  120
    Wait Until Element Is Clicked  xpath:/html/body/div[${DIV_NUMBER}]/div/div[3]/ot-footer/p-button[1]/button  120
    Sleep  ${RESTORE_TIMEOUT}  Timeout for parameter to be restored!
    ${value}  Get Text  ${TABLE_CLASS}/tbody/tr[4]/td[4]/div/ot-instruction/div
    IF  '${value}'=='Succeeded'
        Log  Parameter ${parameter_name} is restored ${value}! [OK]  console=true
    ELSE
        Fail  Restore status for parameter ${parameter_name} is ${value}! [NOK]
    END


Restore Parameters From Oam Domain
    Log  Restore parameters from Oam domain  console=true
    Wait Until Element Is Visible  //*[contains(@aria-label, 'Oam')]  120
    Wait Until Element Is Clicked  xpath=//*[contains(@aria-label, 'Oam')]
    Wait Until Element Is Visible  //*[contains(text(), "Current value")]  120
    Wait Until Element Is Clicked  ${TABLE_CLASS}/tbody/tr/td[4]/div/p-button  120
    Wait Until Element Is Clicked  xpath:/html/body/div[${DIV_NUMBER}]/div/div[3]/ot-footer/p-button[1]/button  120
    Sleep  ${RESTORE_TIMEOUT}  Timeout for parameter to be restored!
    ${parameter_name}  Get Text  ${TABLE_CLASS}/tbody/tr/td[2]
    ${value}  Get Text  ${TABLE_CLASS}/tbody/tr/td[4]/div/ot-instruction/div
    IF  '${value}'=='Succeeded'
        Log  Parameter ${parameter_name} is restored ${value}! [OK]  console=true
    ELSE
        Fail  Restore status for parameter ${parameter_name} is ${value}! [NOK]
    END


Restore Parameters From LteCellP Domain
    Log  \nRestore parameters from LteCellP domain  console=true
    Wait Until Element Is Visible  //*[contains(@aria-label, 'LteCellP')]  120
    Wait Until Element Is Clicked  xpath=//*[contains(@aria-label, 'LteCellP')]
    Wait Until Element Is Visible  //*[contains(text(), "Current value")]  120
    ${parameters_count}  SeleniumLibrary.Get Element Count  ${TABLE_CLASS}/tbody/tr
    FOR  ${index}  IN RANGE  1  ${parameters_count}+1
        Wait Until Element Is Clicked  ${TABLE_CLASS}/tbody/tr[${index}]/td[4]/div/p-button  120
        Wait Until Element Is Clicked  xpath:/html/body/div[${DIV_NUMBER}]/div/div[3]/ot-footer/p-button[1]/button  120
        Sleep  ${RESTORE_TIMEOUT}  Timeout for parameter to be restored!
        ${parameter_name}  Get Text  ${TABLE_CLASS}/tbody/tr[${index}]/td[2]
        ${value}  Get Text  ${TABLE_CLASS}/tbody/tr[${index}]/td[4]/div/ot-instruction/div
        IF  '${value}'=='Succeeded'
            Log  Parameter ${parameter_name} is restored ${value}! [OK]  console=true
        ELSE
            Fail  Restore status for parameter ${parameter_name} is ${value}! [NOK]
        END
    END


Restore Parameters From 5GCPRT Domain
    Log  \nRestore parameters from 5GCPRT domain  console=true
    Wait Until Element Is Visible  //*[contains(@aria-label, '5GCPRT')]  120
    Wait Until Element Is Clicked  xpath=//*[contains(@aria-label, '5GCPRT')]
    Wait Until Element Is Visible  //*[contains(text(), "Current value")]  120
    Wait Until Element Is Clicked  ${TABLE_CLASS}/tbody/tr[4]/td[4]/div/p-button  120
    Wait Until Element Is Clicked  xpath:/html/body/div[${DIV_NUMBER}]/div/div[3]/ot-footer/p-button[1]/button  120
    Sleep  ${RESTORE_TIMEOUT}  Timeout for parameter to be restored!
    ${parameter_name}  Get Text  ${TABLE_CLASS}/tbody/tr[4]/td[2]
    ${value}  Get Text  ${TABLE_CLASS}/tbody/tr[4]/td[4]/div/ot-instruction/div
    IF  '${value}'=='Succeeded'
        Log  Parameter ${parameter_name} is restored ${value}! [OK]  console=true
    ELSE
        Fail  Restore status for parameter ${parameter_name} is ${value}! [NOK]
    END


Apply Changes And Choose The Specific Persistency
    [Arguments]  ${persistency}

    Log  Apply changes and choose the ${persistency} persistency  console=true
    Wait Until Element Is Clicked  xpath=//*[@class="bts-rd-debug-parameter-table"]/div/p-dropdown
    Wait Until Element Is Clicked  //*[contains(@aria-label, '${persistency}')]  120
    Wait Until Element Is Clicked  //*[contains(@class, 'p-button-label ng-star-inserted') and contains(text(), 'Apply Changes')]  120
    Sleep  5s  Timeout for changes to be applied!
    Wait Until Element Is Clicked  xpath:/html/body/div[${DIV_NUMBER}]/div/div[3]/ot-footer/p-button[1]  120
    Wait Until Element Is Visible  //*[contains(text(), "Succeeded")]  300


TC Setup
    Common Test Setup  tc_name=WebEM__RAD_debug_parameters
    WebEM Setup


TC Teardown
    WebEM Teardown
    Common Test Teardown
