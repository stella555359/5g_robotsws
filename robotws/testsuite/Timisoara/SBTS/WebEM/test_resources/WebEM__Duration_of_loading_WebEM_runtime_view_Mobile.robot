*** Settings ***
Documentation
    ...  This TC is created to check if time between Legal Notice and Runtime View is less than 25 seconds.
    ...  The WebEM application shall be able to present the runtime view to the operator within the times defined
    ...  eg. MRAT SBTS (2G+3G+4G+5G) =25 seconds.
    ...  Starting at the moment the WebEM application logins the operator and present him with the legal notice.
    ...  Ending at the moment the WebEM application loads the full runtime view and present it to the operator.

Resource  ../../common_resources/ca_WebEM_mobile.robot


*** Variables ***
${TIME_BETWEEN_LEGAL_AND_RUNTIME}  25s  # Time between Legal Notice and Runtime View


*** Keywords ***
TC__WebEM__Duration_of_loading_WebEM_runtime_view_Mobile
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27360
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 10.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27360 - Initial TAT creation

    Set Tags  CA-WebEM  OWNER-mihnea.spineanu@nokia.com  AUTHOR-cristina.adam@nokia.com  MAINTAINER-cristina.adam@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS24  FEATURE-CB012145

    Step0: Operator Navigates And Open WebEM Via Mobile
    Step1: Check Time Between Legal Notice And Runtime View


Step0: Operator Navigates And Open WebEM Via Mobile
    Log  \nStep0: Operator Navigates And Open WebEM via Mobile  console=true
    Start Web Element Manager On Mobile
    Login SBTS Via Mobile


Step1: Check Time Between Legal Notice And Runtime View
    Log  \nStep1: Check Time Between Legal Notice And Runtime View  console=true
    Wait Until Element Is Visible  //*[contains(text(), 'Accept')]  30
    Click Element  //*[contains(text(), 'Accept')]
    ${status}  Run Keyword And Return Status
    ...  Wait Until Element Is Visible  //*[@id="simplifiedSiteContainer"]/div/div/div/div[2]/div[3]/div[2]/div/div[1]/div/div
    ...  ${TIME_BETWEEN_LEGAL_AND_RUNTIME}
    Run Keyword If  ${status}
    ...  Log  Time Between Legal Notice And Runtime View is less than ${TIME_BETWEEN_LEGAL_AND_RUNTIME} seconds![OK]  console=true
    ...  ELSE
    ...  Fail  Time Between Legal Notice And Runtime View is more than ${TIME_BETWEEN_LEGAL_AND_RUNTIME} seconds![NOK]


TC Setup
    Common Test Setup


TC Teardown
    WebEM Teardown Via Mobile
    Common Test Teardown
