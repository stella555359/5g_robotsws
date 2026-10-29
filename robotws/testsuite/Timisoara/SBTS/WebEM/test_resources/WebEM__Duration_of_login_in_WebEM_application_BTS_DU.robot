*** Settings ***
Documentation
    ...  This TC is created to check if time between Login and Legal Notice is less than 20 seconds.
    ...  The WebEM application shall be able to login the operator within the times defined eg. MRAT SBTS (2G+3G+4G+5G)=20 seconds.
    ...  Starting at the moment the operator initiates the login procedure after inserting the login credentials and click the respective button
    ...  - ending at the moment the WebEM application logins the user into the full WebEM application and present the user with the legal notice.

Resource  ../../common_resources/ca_WebEM_mobile.robot


*** Variables ***
${TIME_BETWEEN_LOGIN_AND_LEGAL}  20s  # Time between Login and Legal Notice


*** Keywords ***
TC__WebEM__Duration_of_login_in_WebEM_application_BTS_DU
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27361
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 14.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27361 - Initial TAT creation

    Set Tags  CA-WebEM  OWNER-mihnea.spineanu@nokia.com  AUTHOR-cristina.adam@nokia.com  MAINTAINER-cristina.adam@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS24  FEATURE-CB012145

    Step0: Operator Navigates And Open WebEM Via Mobile
    Step1: Check Time Between Login And Legal Notice


Step0: Operator Navigates And Open WebEM Via Mobile
    Log  \nStep0: Operator Navigates And Open WebEM via Mobile  console=true
    Start Web Element Manager On Mobile
    Login SBTS Via Mobile


Step1: Check Time Between Login And Legal Notice
    Log  \nStep1: Check Time Between Login And Legal Notice  console=true
    ${status}  Run Keyword And Return Status
    ...  Wait Until Element Is Visible  //*[contains(text(), 'Legal Notice')]  ${TIME_BETWEEN_LOGIN_AND_LEGAL}
    Run Keyword If  ${status}
    ...  Log  Time Between Login and Legal Notice is less than ${TIME_BETWEEN_LOGIN_AND_LEGAL} seconds![OK]  console=true
    ...  ELSE
    ...  Fail  Time Between Login and Legal Notice is more than ${TIME_BETWEEN_LOGIN_AND_LEGAL} seconds![NOK]


TC Setup
    Common Test Setup


TC Teardown
    WebEM Teardown Via Mobile
    Common Test Teardown
