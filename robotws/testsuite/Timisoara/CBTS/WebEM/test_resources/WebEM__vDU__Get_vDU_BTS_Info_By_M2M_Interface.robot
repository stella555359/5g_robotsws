*** Settings ***
Documentation
    ...  This TC is created to get vDU bts info by M2M interface.
    ...  Generate the token and login.
    ...  Get vDU state data with curl command.
    ...  Get vDU state data with KW from taf library.
    ...  Check if mrbtsId, nrDuId and nrbtsId is correct in output from curl command.
    ...  Logout with initial token.

Resource  ../../common_resources/M2M_Interface.robot
Resource  ../../common_resources/vdu_frame.robot


*** Keywords ***
TC__WebEM__vDU__Get_vDU_BTS_Info_By_M2M_Interface
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25165
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 22.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25165 - Initial TAT creation

    Set Tags  CA-WebEM  OWNER-mihnea.spineanu@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS23  FEATURE-CB007823

    Step1:Get VDU State Data With Curl Command
    Step2:Check VDU State Data To Be Correct


Step1:Get VDU State Data With Curl Command
    Log  Step1:Get vDU state data with curl command  console=true
    ${get_vdu_state_data_output}  Run M2M Command  GET  https://${VDU_OAM_IP}/api/licensed/v1/vdu  Bearer  ${TOKEN}
    Set Test Variable  ${GET_VDU_STATE_DATA_OUTPUT}


Step2:Check VDU State Data To Be Correct
    Log  Step2:Check vDU state data to be correct  console=true
    ${vdu_state_data}  vdu.Get Vdu State Data
    ${value_nrdu_id}  Get From Dictionary  ${vdu_state_data}  nr_du_id
    ${status_mrbts_id}  Run Keyword And Return Status
    ...  Should Contain  ${GET_VDU_STATE_DATA_OUTPUT}  "mrbtsId":"${VDU_MRBTS_ID}"
    Run Keyword If  ${status_mrbts_id}
    ...  Log  In command output MRBTS-ID: ${VDU_MRBTS_ID} is visible correctly! [OK]  console=true
    ...  ELSE
    ...  Fail  In command output MRBTS-ID is not visible correctly! [NOK]
    ${status_nrdu_id}  Run Keyword And Return Status
    ...  Should Contain  ${GET_VDU_STATE_DATA_OUTPUT}  "nrDuId":"${value_nrdu_id}"
    Run Keyword If  ${status_nrdu_id}
    ...  Log  In command output NRDU-ID: ${value_nrdu_id} is visible correctly! [OK]  console=true
    ...  ELSE
    ...  Fail  In command output NRDU-ID is not visible correctly! [NOK]
    ${status_nrbts_id}  Run Keyword And Return Status
    ...  Should Contain  ${GET_VDU_STATE_DATA_OUTPUT}  "nrbtsId":"${VDU_NRBTS_ID}"
    Run Keyword If  ${status_nrbts_id}
    ...  Log  In command output NRBTS-ID: ${VDU_NRBTS_ID} is visible correctly! [OK]  console=true
    ...  ELSE
    ...  Fail  In command output NRBTS-ID is not visible correctly! [NOK]


TC Setup
    Common VDU Setup
    Modify Resource Search Order  WebEM__vDU__Get_vDU_BTS_Info_By_M2M_Interface
    Login Using M2M Interface  ${VDU_OAM_IP}


TC Teardown
    Logout Using M2M Interface  ${VDU_OAM_IP}
    Common VDU Teardown
