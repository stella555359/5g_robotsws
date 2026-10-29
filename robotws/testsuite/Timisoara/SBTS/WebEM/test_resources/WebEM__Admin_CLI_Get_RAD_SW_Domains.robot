*** Settings ***
Documentation
    ...  This test case get all R&D domains via ADMIN CLI
    ...  actCli parameter is changed to be true
    ...  Get R&D SW domains name via WebEM from Procedures tab
    ...  Get R&D SW domain name via ADMIN CLI
    ...  Verify for command to be sent with status completed
    ...  Verify if domains from WebEM are the same with domains from ADMIN CLI.
    ...  If lists are not equal, test will fail.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__Admin_CLI_Get_RAD_SW_Domains
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-23853
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 28.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23853 - Initial TAT creation
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice
    ...  - 15.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24316 - Refactor WebEM TCs and resources to use KWs from ca_SBTS_general

    Set Tags  CA-WebEM  OWNER-nicolae-marcel.caragel@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS23

    Step1: Change ActCli Parameter To Be true
    Step2: Get R&D SW Domain Name Via WebEM
    Step3: Get R&D SW Domain Name Via ADMIN CLI
    Step4: Change ActCli Parameter To Be false


Step${id}: Change ActCli Parameter To Be ${value}
    Log  \nStep${id}: Change actCli parameter to be ${value}  console=true
    Change ActCli Parameter  ${value}


Step2: Get R&D SW Domain Name Via WebEM
    Log  \nStep2: Get R&D SW domain name via WebEM  console=true
    Open BTS R&D Debug Parameters Management
    Wait Until Element Is Visible  //*[contains(text(), "Please select a domain from list to get its parameters.")]  120
    ${list_of_domains_from_webem}  Create List
    ${domains}  SeleniumLibrary.Get Element Count  //*[@id="p-tabpanel-0"]/rad-debug-parameters/div/div/div/div[1]/p-listbox/div/div[2]/ul/li
    FOR  ${domain}  IN RANGE  1  ${domains}+1
        ${domain_name}  Get Text  //*[@id="p-tabpanel-0"]/rad-debug-parameters/div/div/div/div[1]/p-listbox/div/div[2]/ul/li[${domain}]
        Append To List  ${list_of_domains_from_webem}  ${domain_name}
    END
    Log  List of domains from WebEM: ${list_of_domains_from_webem}  console=true
    Set Test Variable  ${LIST_OF_DOMAINS_FROM_WEBEM}


Step3: Get R&D SW Domain Name Via ADMIN CLI
    Log  \nStep3: Get R&D SW domain name via ADMIN CLI  console=true
    Setup Admin CLI  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}
    ${request}  Set Variable  {"requestId":1,"parameters":{"name":"getRADSWDomains"}}
    Log  Sending command via Admin CLI for getRADSWDomains...  console=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  ${request}
    Run Keyword If  '${request_status}' == 'completed'
    ...  Log  Command sent with status: ${request_status}  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status} and error code: ${error_code}
    Log  List of domains from ADMIN CLI: ${request_message}  console=true
    ${status}  Run Keyword And Return Status
    ...  Lists Should Be Equal  ${LIST_OF_DOMAINS_FROM_WEBEM}  ${request_message}
    Run Keyword If  ${status}
    ...  Log  \nDomains are equal in WebEM as in ADMIN CLI response![OK]  console=true
    ...  ELSE
    ...  Fail  Domains are not equal in WebEM as in ADMIN CLI response![OK]


TC Setup
    Common Test Setup  tc_name=WebEM__Admin_CLI_Get_RAD_SW_Domains
    WebEM Setup


TC Teardown
    WebEM Teardown
    Common Test Teardown
