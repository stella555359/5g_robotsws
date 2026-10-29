*** Settings ***
Resource    ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${DISABLED_TIMEOUT}                        300  #Time for SBTS to be disabled.
${RECOVERY_TIMEOUT}                        1200  #Time for SBTS to recovery.
${MODULE_RECOVERY_TIMEOUT_AFTER_UNLOCK}    150  #Time for module to recovery.


*** Keywords ***
TC__WebEM__Baseband_module_lock_unlock
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21626
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This test case is created to perform baseband lock unlock.
    ...  Verify if all cells on SBTS are working.
    ...  Lock BBMODs is performed.
    ...  Check cells on BBMOD to be Dependency
    ...  Check if lock icon appeard on BBMOD in site view.
    ...  Check if lock icon appeard on BBMOD in detailed site view.
    ...  Unlock BBMODs id performed.
    ...  Check cells on BBMOD to be Online
    ...  Check if lock icon disappeared from BBMOD in site view.
    ...  Check if lock icon disappeared from BBMOD in detailed site view.
    ...  History of changes
    ...  ******************
    ...  - 22.07.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21626 - Initial TAT creation
    ...  - 11.01.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22470 - Fixed check for cells deployment
    ...  - 19.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23935 - Remove KWs changed in resource
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice
    ...  - 15.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24316 - Refactor WebEM TCs and resources to use KWs from ca_SBTS_general

    Set Tags    CA-WebEM    OWNER-emina.stefanovici@nokia.com    AUTHOR-andreea.burtic@nokia.com
    ...    MAINTAINER-andreea.burtic@nokia.com    GROUP_IN_CHARGE-TIM_3_Vrf    PHASE-CRT    SW-SBTS21B

    Step0: TC Preconditions
    Step1: Lock BBMODs and verify cells
    Step2: Verify if BBMODs are locked in Detailed Site View
    Step3: Unlock BBMODs and verify cells
    Step4: Verify if BBMODs are unlocked in Detailed Site View


Step0: TC Preconditions
    ${BBMODS_XPATH}  Get xpaths for BBMODs
    Set Test Variable  ${BBMODS_XPATH}
    Check all cells from WebEM

Step1: Lock BBMODs and verify cells
    Log  Step1: Lock BBMODs and verify cells  console=true
    FOR  ${bbmod}  IN  @{BBMODS_XPATH}
       Wait Until Keyword Succeeds  120  10  Lock module  ${bbmod}
       Click Element  ${bbmod}
       ${bbmod_title}  Get Text  ${bbmod}/div/div[2]/div[1]
       ${bbmod_text}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div[2]/details-panel/div/wf-panel
       ...  /wf-panel-section/div/div/details-panel-content/div/hardware-details/div/div/div[1]/div/div/div[2]
       ...  /div[1]/div[1]/span
       ${bbmod_name}  Get Text  ${bbmod_text}
       ${status}  Run Keyword and Return Status  Wait Until Keyword Succeeds  ${DISABLED_TIMEOUT}  10
       ...  Check all states for BBMOD  ${bbmod}  Online|-  Enabled|enabled  Locked|locked
       Run keyword if  ${status}
       ...  Log  ${bbmod_name}:${bbmod_title} is Locked.  console=true
       ...  ELSE
       ...  Fail  ${bbmod_name}:${bbmod_title} is not Locked after performing lock operation.
       Verify if locked icon is visible  ${bbmod}  ${bbmod_name}
    END
    ${status}  Run keyword and return status  Wait Until Keyword Succeeds  ${DISABLED_TIMEOUT}  10  Check cells to be Dependency  ${Dependency_}
    Run Keyword If  ${status}
    ...  Log  All cells are Dependency![OK]  console=true
    ...  ELSE
    ...  Fail  Not all cells are Dependency![NOK]

Step2: Verify if BBMODs are locked in Detailed Site View
    Log  Step2: Verify if BBMODs are locked in Detailed Site View  console=true
    Click Element  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div/site-runtime-views/div/ul/li[2]
    ${bbmod_index}  Get Length  ${BBMODS_XPATH}
    FOR  ${index}  IN RANGE  1  ${bbmod_index}+1
        ${status}  Run keyword and return status  Wait until Element is Visible
        ...  xpath=//*[contains(@aria-label, 'Baseband Module ${index}')]/div[1]/div[3]/div[1]  ${DISABLED_TIMEOUT}
        Run keyword if  ${status}
        ...  Log  Locked icon is visible in Detailed Site View for Baseband Module ${index}![OK]  console=true
        ...  ELSE
        ...  Fail  Locked icon is not visible in Detailed Site View for Baseband Module ${index}![NOK]
    END
    Go To Site View

Step3: Unlock BBMODs and verify cells
    Log  Step3: Unlock BBMODs and verify cells  console=true
    FOR  ${bbmod}  IN  @{BBMODS_XPATH}
        Wait Until Keyword Succeeds  120  5  Unlock module  ${bbmod}
        Click Element  ${bbmod}
        ${bbmod_title}  Get Text  ${bbmod}/div/div[2]/div[1]
        ${bbmods_text}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div[2]/details-panel/div/wf-panel/wf-panel-section
        ...  /div/div/details-panel-content/div/hardware-details/div/div/div[1]/div/div/div[2]/div[1]/div[1]/span
        ${bbmod_name}  Get Text  ${bbmods_text}
        ${status}  Run Keyword and Return Status  Wait Until Keyword Succeeds  ${MODULE_RECOVERY_TIMEOUT_AFTER_UNLOCK}  10
        ...  Check all states for BBMOD  ${bbmod}  Online|-  Enabled|enabled  Unlocked|unlocked
        Run keyword if  ${status}
        ...  Log  ${bbmod_name}:${bbmod_title} is Unlocked.  console=true
        ...  ELSE
        ...  Fail  ${bbmod_name}:${bbmod_title} is not Unlocked after performing unlock operation.
        Verify if locked icon is not visible  ${bbmod}  ${bbmod_name}
    END
    ${status}  Run keyword and return status  Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}
    Run Keyword If  ${status}
    ...  Log  All cells are Enabled![OK]  console=true
    ...  ELSE
    ...  Set test failed  Not all cells are Enabled![NOK]

Step4: Verify if BBMODs are unlocked in Detailed Site View
    Log  Step4: Verify if BBMODs are unlocked in Detailed Site View  console=true
    ${bbmods}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section
    ...  /div/div/site-runtime-views/div/ul/li[2]
    Click Element  ${bbmods}
    ${bbmod_index}  Get Length  ${BBMODS_XPATH}
    FOR  ${index}  IN RANGE  1  ${bbmod_index}+1
        Wait until Element is Visible  xpath=//*[contains(@aria-label, 'Baseband Module ${index}')]/div[1]/div[3]/div[1]  ${DISABLED_TIMEOUT}
        ${bbmod_class}  Selenium2Library.Get Element Attribute  xpath=//*[contains(@aria-label, 'Baseband Module ${index}')]/div[1]/div[3]/div[1]
        ...  class
        Run keyword if  '${bbmod_class}'=='locked-icon'
        ...  Fail  Lock icon is visible for Baseband Module ${index} after unlock action![NOK]
        ...  ELSE
        ...  Log  Lock icon is not visible for Baseband Module ${index} after unlock action![OK]  console=true
    END
    Go To Site View

Check cells to be Dependency
    [Arguments]  ${availabilityState}
    Run Keyword If  ${SCF_COUNT_WCDMA}
    ...  Assert Every    WNCEL    availabilityStatus=${availabilityState}  timeout=60
    Run Keyword If  ${SCF_COUNT_LTE}
    ...  Assert Every    LNCEL    availabilityStatus=${availabilityState}  timeout=60
    Run Keyword If  ${SCF_COUNT_GSM}
    ...  Assert Every    GNCEL    availabilityStatus=${availabilityState}  timeout=60
    Run Keyword If  ${SCF_COUNT_NR}
    ...  Assert Every    NRCEL    availabilityStatus=${availabilityState}  timeout=60

Verify if locked icon is visible
    [Arguments]  ${module_xpath}  ${module_name}
    ${status}  Run keyword and return status   Wait until Element is Visible  ${module_xpath}/div/div[3]/div[1]  ${DISABLED_TIMEOUT}
    Run keyword if  ${status}
    ...  Log  Lock icon is visible for ${module_name} after lock action!  console=true
    ...  ELSE
    ...  Fail  Lock icon is not visible for ${module_name} after ${DISABLED_TIMEOUT}s!

Verify if locked icon is not visible
    [Arguments]  ${module_xpath}  ${module_name}
    ${bbmod_class}  Selenium2Library.Get Element Attribute  ${module_xpath}/div/div[3]/div[1]  class
    Run keyword if  '${bbmod_class}'=='locked-icon'
    ...  Fail  Lock icon is visible for ${module_name} after unlocked action!
    ...  ELSE
    ...  Log  Locked icon is not visible for ${module_name} after unlocked action!  console=true

TC Setup
    Common test setup
    WebEM Setup

TC Teardown
    WebEM Teardown
    Common test teardown
