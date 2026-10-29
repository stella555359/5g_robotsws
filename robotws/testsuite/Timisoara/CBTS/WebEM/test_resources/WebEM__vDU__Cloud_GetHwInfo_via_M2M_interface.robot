*** Settings ***
Documentation
    ...  This TC is created to get information about vDU hardware via M2M interface.
    ...  Generate the token and login.
    ...  Get hardware data with curl command.
    ...  Verify current date and time.
    ...  Logout with initial token.

Resource  ../../common_resources/M2M_Interface.robot
Resource  ../../common_resources/vdu_frame.robot


*** Keywords ***
TC__WebEM__vDU__Cloud_GetHwInfo_via_M2M_interface
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26553
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  07.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26553 - Initial TAT creation
    ...  ******************

    Set Tags  CA-WebEM  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-anna.benzar@nokia.com  MAINTAINER-anna.benzar@nokia.com  GROUP_IN_CHARGE-TIM_1_Vrf
    ...  PHASE-CRT  FEATURE-CB010545

    Step 1: Get Hardware Info


Step 1: Get Hardware Info
    Log  \nStep 1: Get hardware info .  console=true
    ${current_date_time}  Get Current Date  time_zone=UTC  exclude_millis=True
    ${current_date}  Fetch From Left  ${current_date_time}  ${SPACE}
    ${start_time}  Get Regexp Matches  ${current_date_time}  [0-9]{2}:[0-9]{2}
    ${hw_info}  Run M2M Command  GET  https://${VDU_OAM_IP}:443/api/licensed/v1/getHwInfo  Bearer  ${TOKEN}
    ${hw_info}  Remove M2M Output Noise  ${hw_info}
    ${hw_info}  Remove String Using Regexp  ${hw_info}  (${SPACE}+:00.+None|curl.+None)
    ${hw_info}  Evaluate  json.loads('''${hw_info}''')  json
    ${current_date_m2m}  Fetch From Left  ${hw_info}[currentTime]  T
    ${current_time_m2m}  Fetch From Right  ${hw_info}[currentTime]  T
    ${current_time_m2m}  Fetch From Left  ${current_time_m2m}  +
    ${current_time_m2m}  Get Regexp Matches  ${current_time_m2m}  [0-9]{2}:[0-9]{2}
    Should Be Equal  ${current_date}  ${current_date_m2m}  Date is not correctly set. [NOK]
    Should Be Equal  ${start_time}[0]  ${current_time_m2m}[0]  Time is not correctly set. [NOK]
    Log  Date and time are correct. [OK]  console=true


TC Setup
    Common VDU Setup
    Modify Resource Search Order  WebEM__vDU__Cloud_GetHwInfo_via_M2M_interface
    Login Using M2M Interface  ${VDU_OAM_IP}


TC Teardown
    Logout Using M2M Interface  ${VDU_OAM_IP}
    Common VDU Teardown
