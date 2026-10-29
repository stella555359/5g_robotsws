*** Settings ***
Documentation
    ...  This TC is created to check if the WebEM application is retrieved and loaded in the browser within 5 seconds.
    ...  The operator navigates to the WebEM URL (https://192.168.255.129/1).
    ...  The WebEM application shall be retrieved and loaded in the browser within 5 seconds for MRAT SBTS (2G+3G+4G+5G),
    ...  starting at the moment the operator navigates to the WebEM URL and ending at the moment the WebEM application is loaded in the browser
    ...  and the login window visible to the operator.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${WEB_ELEMENT_MANAGER_TIMEOUT}  5s  # Timeout until Web Element Manager appear


*** Keywords ***
TC__WebEM__Duration_of_loading_WebEM_application_Web
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27366
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 14.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27366 - Initial TAT creation

    Set Tags  CA-WebEM  OWNER-mihnea.spineanu@nokia.com  AUTHOR-cristina.adam@nokia.com  MAINTAINER-cristina.adam@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS24  FEATURE-CB012145

    Step0: Operator Navigates To WebEM URL And Check Page Load Time


Step0: Operator Navigates To WebEM URL And Check Page Load Time
    Log  \nStep0: Operator navigates to WebEM URL and check page load time  console=true
    ${chrome_options}  Evaluate  sys.modules['selenium.webdriver'].ChromeOptions()  sys, selenium.webdriver
    ${prefs}  Create Dictionary  download.default_directory=/home/ute/Downloads
    Call Method  ${chrome_options}  add_experimental_option  prefs  ${prefs}
    Call Method  ${chrome_options}  add_argument  --ignore-ssl-errors
    Call Method  ${chrome_options}  add_argument  --ignore-certificate-errors
    Call Method  ${chrome_options}  add_argument  --disable-popup-blocking
    Run Keyword If  ${TAF_CONFIG_MODEL}
    ...  Call Method  ${chrome_options}  add_argument  --headless
    Create Webdriver  Chrome  options=${chrome_options}
    Go To  https://192.168.255.129
    Check Web Element Manager Is Visible


Check Web Element Manager Is Visible
    ${status}  Run Keyword And Return Status
    ...  Wait Until Element Is Visible  //div[contains(text(),' Web Element Manager ')]  ${WEB_ELEMENT_MANAGER_TIMEOUT}
    Run Keyword If  ${status}
    ...  Log  The WebEM application loads in the browser in ${WEB_ELEMENT_MANAGER_TIMEOUT} seconds![OK]  console=true
    ...  ELSE
    ...  Fail  The WebEM application doesn't load in browser within ${WEB_ELEMENT_MANAGER_TIMEOUT} seconds![NOK]


TC Setup
    Common Test Setup


TC Teardown
    WebEM Teardown
    Common Test Teardown
