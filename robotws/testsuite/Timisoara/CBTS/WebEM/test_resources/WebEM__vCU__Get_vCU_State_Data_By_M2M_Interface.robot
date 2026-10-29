*** Settings ***
Documentation
    ...  This TC is created to get vCU bts info by M2M interface.
    ...  Generate the token and login.
    ...  Get vCU state data with curl command and verify if nrbtsId is correct in the generated output.
    ...  Logout with initial token.

Resource  ../../common_resources/M2M_Interface.robot
Resource  ../../common_resources/vcu_frame.robot


*** Keywords ***
TC__WebEM__vCU__Get_vCU_State_Data_By_M2M_Interface
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25166
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  04.04.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25166 - Initial TAT creation
    ...  ******************

    Set Tags  CA-WebEM  OWNER-mihnea.spineanu@nokia.com  AUTHOR-anna.benzar@nokia.com  MAINTAINER-anna.benzar@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf
    ...  PHASE-CRT  FEATURE-CB007823

    Step 1: Get VCU State Data With Curl Command
    Step 2: Check VCU State


Step 1: Get VCU State Data With Curl Command
    Log  \nStep 1: Get vCU state data with curl command.  console=true
    ${curl_output}  Run M2M Command  GET  https://${VCU_OAM_IP}/api/licensed/v1/cu  Bearer  ${TOKEN}
    Set Test Variable  ${CURL_OUTPUT}


Step 2: Check VCU State
    Log  \nStep 2: Check vCU state.  console=true
    ${status_nrbts_id}  Run Keyword And Return Status
    ...  Should Contain  ${CURL_OUTPUT}  "nrbtsId":"${VCU_NRBTS_ID}"
    Run Keyword If  ${status_nrbts_id}
    ...  Log  NRBTS-ID is visible correctly in command output: ${VCU_NRBTS_ID}. [OK]  console=true
    ...  ELSE
    ...  Fail  NRBTS-ID is not visible correctly in command output! [NOK]


TC Setup
    Common VCU Setup
    Modify Resource Search Order  WebEM__vCU__Get_vCU_State_Data_By_M2M_Interface
    Login Using M2M Interface  ${VCU_OAM_IP}


TC Teardown
    Logout Using M2M Interface  ${VCU_OAM_IP}
    Common VCU Teardown
