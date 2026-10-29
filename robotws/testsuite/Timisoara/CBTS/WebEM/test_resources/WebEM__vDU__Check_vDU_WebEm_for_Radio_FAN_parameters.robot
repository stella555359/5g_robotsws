*** Settings ***
Documentation
    ...  Open Site View.
    ...  Check That All Fan Icons Are Clickable.
    ...  Check details from each Fans.

Resource  ../resources/vdu_WebEM_general.robot
Resource  ../../common_resources/vdu_frame.robot


*** Keywords ***
TC__WebEM__vDU__Check_vDU_WebEm_for_Radio_FAN_parameters
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25023
    ...
    ...  ******************
    ...  - 21.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25023 - Initial TAT creation
    ...  - 18.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28072 - Changes since CB008388

    Set Tags  CA-WebEM  OWNER-lucian.ivanescu@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS23  FEATURE-CB009275  FEATURE-CB008388

    Step1:Open Site View
    Step2:Check That The Fan Icons Are Clickable
    Step3:Check Details From Fans


Step1:Open Site View
    Log  \nStep1:Open Site View  console=true
    Wait Until Element Is Clicked  ${VDU_SITE_VIEW}
    Log  Site View is open![OK]  console=true


Step2:Check That The Fan Icons Are Clickable
    Log  \nStep2:Check That The Fan Icons Are Clickable  console=true
    Log  Check Fans to be visible  console=true
    Wait Until Element Is Visible  //div[@class="rmods ng-star-inserted"]  10
    ${fan_elements}  Get WebElements  //div[contains(@class, "rmod-fan ng-star-inserted")]
    Set Test Variable  ${FAN_ELEMENTS}
    ${fans_number}  Get Length  ${fan_elements}
    Log  ${fans_number} Fans are available!  console=true
    Log  Check Fans to be clickable  console=true
    FOR  ${element}  IN  @{fan_elements}
        Click Element  ${element}
        ${fan_id}  Get Element Attribute  ${element}  data-fan-id
        ${fan_class}  Get Element Attribute  ${element}  class
        Should Contain  ${fan_class}  selected  FAN-${fan_id} was not selected after the button is pushed![NOK]
        Log  FAN-${fan_id} was selected after the button is pushed![OK]  console=true
    END


Step3:Check Details From Fans
    Log  \nStep3:Check Details from Fans  console=true
    Wait Until Element Is Clicked  //*[@id="open-detail-panel-button"]
    FOR  ${element}  IN  @{fan_elements}
        Click element  ${element}
        ${fan_id}  Get Element Attribute  ${element}  data-fan-id
        Log  Check parameters in Details panel for FAN-${fan_id}!  console=true
        Check Parameters In Details Panel  ${fan_id}
    END


Check Parameters In Details Panel
    [Arguments]  ${fan}

    ${overview_list}  Create List  Administrative state  Unlocked  Availability status  On line  Operational state  Enabled  Usage state  Idle
    FOR  ${parameter}  IN  @{overview_list}
        Wait Until Keyword Succeeds  30  5
        ...  Page Should Contain Element  //*[contains(@title, '${parameter}')]
        Log  ${parameter} is visible![OK]  console=true
    END
    Click Element  //span[contains(@class, 'p-tabview-title ng-star-inserted') and contains(text(), 'Parameters')]
    ${parameter_list}  Create List  Administrative state  Unlocked  RUs FAN location  RUs FAN presence  true  Operational state  enabled  Usage state
    ...  Idle
    FOR  ${parameter}  IN  @{parameter_list}
        Wait Until Keyword Succeeds  30  5
        ...  Page Should Contain Element  //*[contains(text(), "${parameter}")]
        Log  ${parameter} is visible![OK]  console=true
    END
    IF  ${fan} == 1
      Page Should Contain Element  //*[contains(text(), "0")]
      Log  Location 0 is visible![OK]  console=true
    ELSE
      Page Should Contain Element  //*[contains(text(), "1")]
      Log  Location 1 is visible![OK]  console=true
    END
    Click Element  //span[contains(@class, 'p-tabview-title ng-star-inserted') and contains(text(), 'Overview')]


TC Setup
    Common VDU Setup
    VDU WebEM Setup
    Modify Resource Search Order  WebEM__vDU__Check_vDU_WebEm_for_Radio_FAN_parameters


TC Teardown
    VDU WebEM Teardown
    Common VDU Teardown
