*** Settings ***
Documentation
    ...  This test case is created to perform IP Connectivity test with All Configurated Hosts.
    ...  Open Ip Connectivity Test and choose All Configurated Hosts.
    ...  Starting the test with the minimum values of payload and dscp.
    ...  Verify if pings are passed or timeout.
    ...  If all pings are passed, the test will be PASS, if at least one ping are passed,
    ...  the test will be PASSED WITH RESTRICTIONS and if all pings are timeout, the test will be FAIL.
    ...  Starting the test with the maximum values of payload and dscp.
    ...  Verify if pings are passed or timeout.
    ...  If all pings are passed, the test will be PASS, if at least one ping are passed,
    ...  the test will be PASSED WITH RESTRICTIONS and if all pings are timeout, the test will be FAIL.
    ...  Starting the test with random values of payload and dscp.
    ...  Verify if pings are passed or timeout.
    ...  If all pings are passed, the test will be PASS, if at least one ping are passed,
    ...  the test will be PASSED WITH RESTRICTIONS and if all pings are timeout, the test will be FAIL.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__IP_Connectivity_test
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21611
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 20.07.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21611 - Initial TAT creation
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice

    Set Tags  CA-WebEM  OWNER-george.gheban@nokia.com  AUTHOR-andreea.burtic@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS21B

    Step1: Open IP Connectivity Test With All Configured Hosts
    Step2: All Configured Hosts With Minimum Values
    Step3: All Configured Hosts With Maximum Values
    Step4: All Configured Hosts With Random Values


Step1: Open IP Connectivity Test With All Configured Hosts
    Log  Step1: Open IP Connectivity Test with All Configured Hosts  console=true
    Open IP Connectivity Test
    ${config}  Catenate  SEPARATOR=  //*[contains(@class, "ip-connectivity-test-container")]
    ...  /div/ip-connectivity-test-input/form/div/div[1]/div/wf-dropdown/div
    Click Element  ${config}
    Click Element  xpath=//*[contains(@data-value, 'All configured hosts')]
    Log  Open IP Connectivity Test with All Configured Hosts has been successfully completed!  console=true
    ${values_of_payload}  Get Text  //*[@id="ip-connectivity-paload-size-describe"]
    ${payload_values}  Fetch From Left  ${values_of_payload}  .
    ${payload_min_value}  Fetch From Right  ${payload_values}  [
    Set Test Variable  ${PAYLOAD_MIN_VALUE}
    ${payload_val}  Fetch From Right  ${values_of_payload}  ...
    ${payload_max_value}  Fetch From Left  ${payload_val}  ]
    Set Test Variable  ${PAYLOAD_MAX_VALUE}
    ${values_of_dscp}  Get Text  //*[@id="ip-connectivity-dscp-describe"]
    ${dscp_values}  Fetch From Left  ${values_of_dscp}  .
    ${dscp_min_value}  Fetch From Right  ${dscp_values}  [
    Set Test Variable  ${DSCP_MIN_VALUE}
    ${dscp_val}  Fetch From Right  ${values_of_dscp}  ...
    ${dscp_max_value}  Fetch From Left  ${dscp_val}  ]
    Set Test Variable  ${DSCP_MAX_VALUE}


Step2: All Configured Hosts With Minimum Values
    Log  Step2: All configured hosts with minimum values  console=true
    Values For Payload And Dscp  ${PAYLOAD_MIN_VALUE}  ${DSCP_MIN_VALUE}
    ${info_view}  Catenate  SEPARATOR=  //*[contains(@class, "ip-connectivity-test-container")]
    ...  /div/ip-connectivity-info-table/section/div/ui-button[1]/button
    Set Test Variable  ${INFO_VIEW}
    Click Element  ${INFO_VIEW}
    Sleep  5s
    Wait Until Element Is Enabled  ${INFO_VIEW}  300
    Check Ping Results


Step3: All Configured Hosts With Maximum Values
    Log  Step3: All configured hosts with maximum values  console=true
    Values For Payload And Dscp  ${PAYLOAD_MAX_VALUE}  ${DSCP_MAX_VALUE}
    Click Element  ${INFO_VIEW}
    Sleep  5s
    Wait Until Element Is Enabled  ${INFO_VIEW}  300
    Check Ping Results


Step4: All Configured Hosts With Random Values
    Log  Step4: All configured hosts with random values  console=true
    ${random_payload_value}  Evaluate  random.randint(${PAYLOAD_MIN_VALUE}+1, ${PAYLOAD_MAX_VALUE}-1)  modules=random
    ${random_dscp_value}  Evaluate  random.randint(${DSCP_MIN_VALUE}+1, ${DSCP_MAX_VALUE}-1)  modules=random
    Values For Payload And Dscp  ${random_payload_value}  ${random_dscp_value}
    Click Element  ${INFO_VIEW}
    Sleep  3s
    Wait Until Element Is Enabled  ${INFO_VIEW}  300
    Check Ping Results


Values For Payload And Dscp
    [Arguments]  ${payload_value}  ${dscp_value}

    Clear Element Text  xpath=//*[contains(@name, 'payload')]
    Clear Element Text  xpath=//*[contains(@name, 'dscp')]
    Input Text  xpath=//*[contains(@name, 'payload')]  ${payload_value}
    Input Text  xpath=//*[contains(@name, 'dscp')]  ${dscp_value}


Check Ping Results
    ${row}  SeleniumLibrary.Get Element Count  class:ping-result
    ${ping_results}  Create List
    FOR  ${id}  IN RANGE  1  ${row}+1
        ${name_text}  Catenate  SEPARATOR=  //*[contains(@class, "ip-connectivity-test-container")]
        ...  /div/ip-connectivity-info-table/section/ui-table/div/ng-transclude/table/tbody/tr[${id}]
        ${name}  Get Text  ${name_text}
        ${ping_text}  Catenate  SEPARATOR=  //*[contains(@class, "ip-connectivity-test-container")]
        ...  /div/ip-connectivity-info-table/section/ui-table/div/ng-transclude/table/tbody/tr[${id}]/td[3]/div/ip-connectivity-info-table-row/
        ...  span/input
        ${ping}  SeleniumLibrary.Get Element Attribute  ${ping_text}  value
        Log  ${name}:${ping}  console=true
        Append To List  ${ping_results}  ${ping}
    END
    Log  Ping status:  console=true
    ${result_passed}  Run Keyword And Return Status
    ...  List Should Contain Value  ${ping_results}  Passed
    ${result_timeout}  Run Keyword And Return Status
    ...  List Should Contain Value  ${ping_results}  Timeout
    Run Keyword If  ${result_passed}==${FALSE}
    ...  Set Test Failed  All pings are timeout!
    Run Keyword If  ${result_passed} and ${result_timeout}
    ...  Set Test Restriction  Not all pings are passed!
    Run Keyword If  ${result_timeout}==${FALSE}
    ...  Log  All pings are passed!  console=true


TC Setup
    Common Test Setup
    WebEM Setup


TC Teardown
    WebEM Teardown
    Common Test Teardown
