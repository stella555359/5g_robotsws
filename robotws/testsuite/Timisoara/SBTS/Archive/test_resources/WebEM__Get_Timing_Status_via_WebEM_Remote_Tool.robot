*** Settings ***
Resource    ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__Get_Timing_Status_via_WebEM_Remote_Tool
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24259
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This test case is transferred from BOAM_ET to ST_OAM_WebEM.
    ...  This test case gets timing status.
    ...  Verify if status exists and gets the value.
    ...  Verify if type exists and gets the value.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 13.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24259 - Initial TAT creation

    Set Tags    CA-WebEM    OWNER-cristina.antoci@nokia.com     AUTHOR-andreea.burtic@nokia.com
    ...    MAINTAINER-andreea.burtic@nokia.com    GROUP_IN_CHARGE-TIM_3_Vrf    PHASE-CRT    SW-SBTS23

    Step1: Get timing status


Step1: Get timing status
    Log  \nStep1: Get timing status  console=true
    ${time_info}  coam.Get Timing Status
    Dictionary Should Contain Key  ${time_info[0]}  status
    ${status}  Get From Dictionary  ${time_info[0]}  status
    Log  Values for status are ${status}!  console=true
    Dictionary Should Contain Key  ${time_info[0]}  type
    ${value_type}  Get From Dictionary  ${time_info[0]}  type
    Log  Value for type is ${value_type}!  console=true


TC Setup
    Common test setup

TC Teardown
    Common test teardown


