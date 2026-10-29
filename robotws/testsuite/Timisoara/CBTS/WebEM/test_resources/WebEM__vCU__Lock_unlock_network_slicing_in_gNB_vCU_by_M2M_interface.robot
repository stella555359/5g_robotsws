*** Settings ***
Documentation
    ...  This TC is created to verify operations on vCU network slicing.
    ...  Generate the token and login.
    ...  The request operations that are sent, are: POST, GET, DELETE.
    ...  Lock and unlock operations are performed by using network slicing dist name.
    ...  Two bad lock requests are sent: the first one is sent with network slicing dist name and cell dist name.
    ...  The second bad lock request is sent on a network slicing dist name that doesn't exist.
    ...  Logout with initial token.

Resource  ../../common_resources/M2M_Interface.robot
Resource  ../../common_resources/vcu_frame.robot
Resource  ../../common_resources/vdu_frame.robot


*** Variables ***
${RECOVERY_TIMEOUT}  900s  # Timeout for CBTS to be onAir


*** Keywords ***
TC__WebEM__vCU__Lock_unlock_network_slicing_in_gNB_vCU_by_M2M_interface
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25195
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  06.04.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25195 - Initial TAT creation
    ...  ******************

    Set Tags  CA-WebEM  OWNER-mihnea.spineanu@nokia.com  AUTHOR-anna.benzar@nokia.com  MAINTAINER-anna.benzar@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf
    ...  PHASE-CRT  FEATURE-CB006590

    Step 0: TC Prerequisites
    Step 1: Send REST API Network Slicing LOCK Request
    Step 2: Send REST API GET Request
    Step 3: Send REST API DELETE Request
    Step 4: Send REST API Second GET Request
    Step 5: Send REST API Network Slicing UNLOCK Request
    Step 6: Send REST API First Bad LOCK Request
    Step 7: Send REST API Second Bad LOCK Request


Step 0: TC Prerequisites
    Log  \nStep 0: TC Prerequisites.  console=true
    ${vdu_cells}  vdu.Get Vdu Cells Status
    ${cell_dn}  Set Variable  ${vdu_cells}[0][dist_names][config]
    ${network_slicing}  vcu.Get Network Slicing
    ${network_slicing_dn}  Set Variable  ${network_slicing}[0][dist_names][config]
    ${network_slicing_status}  Run Keyword And Return Status
    ...  Verify Network Slicing State  ${UNLOCKED}
    ${network_slicing_id}  Create List  ${network_slicing}[0][snssai_id]
    Run Keyword If  ${network_slicing_status}==${FALSE}
    ...  vcu.Unlock Network Slicing  ${network_slicing_id}
    Verify Network Slicing State  ${UNLOCKED}
    Set Test Variable  ${CELL_DN}
    Set Test Variable  ${NETWORK_SLICING_DN}


Step 1: Send REST API Network Slicing LOCK Request
    Log  \nStep 1: Send REST API network slicing LOCK request.  console=true
    ${lock_request_output}  Run M2M Command  POST  "https://${VCU_OAM_IP}/api/licensed/v1/network-slicing/operations/locks"  Bearer  ${TOKEN}
    ...  -d "{\\"dns\\":[\\"${NETWORK_SLICING_DN}\\"]}"
    Should Contain  ${lock_request_output}  "status":"ongoing"
    Log  Network slicing LOCK request sent, "status":"ongoing". [OK]  console=true
    ${operation_id}  Get Operation Id Value  ${lock_request_output}
    Set Test Variable  ${OPERATION_ID}
    ${network_slicing_response}  vcu.Get Operate Network Slicing State  ${OPERATION_ID}
    ${message_status}  Run Keyword And Return Status
    ...  Should Not Contain  ${network_slicing_response}  'error_message': 'Get lock unlock MO changes conflict'
    Run Keyword If  ${message_status}==${FALSE}
    ...  Fail  Error message: "Get lock unlock MO changes conflict" [NOK].
    Wait Until Keyword Succeeds  180s  10s
    ...  Verify Network Slicing State  ${LOCKED}
    Log  Network slicing locked successfully. [OK]  console=true


Step 2: Send REST API GET Request
    Log  \nStep 2: Send REST API GET request.  console=true
    ${get_request_output}  Run M2M Command  GET  "https://${VCU_OAM_IP}:443/api/licensed/v1/operations/${OPERATION_ID}?type=lock_unlock"  Bearer
    ...  ${TOKEN}
    Should Contain  ${get_request_output}  "status":"success"
    Log  GET request sent, "status":"success". [OK]  console=true


Step 3: Send REST API DELETE Request
    Log  \nStep 3: Send REST API DELETE request.  console=true
    Run M2M Command  DELETE  "https://${VCU_OAM_IP}/api/licensed/v1/operations/${OPERATION_ID}?type=lock_unlock"  Bearer  ${TOKEN}
    Log  DELETE request sent. [OK]  console=true


Step 4: Send REST API Second GET Request
    Log  \nStep 4: Send REST API second GET request.  console=true
    ${get_request_output}  Run M2M Command  GET  "https://${VCU_OAM_IP}/api/licensed/v1/operations/${OPERATION_ID}?type=lock_unlock"  Bearer
    ...  ${TOKEN}
    Should Contain  ${get_request_output}  "summary":"Get operation failed"
    Log  Second GET request sent, "summary":"Get operation failed". [OK]  console=true


Step 5: Send REST API Network Slicing UNLOCK Request
    Log  \nStep 5: Send REST API network slicing UNLOCK request.  console=true
    ${unlock_request_output}  Run M2M Command  POST  "https://${VCU_OAM_IP}/api/licensed/v1/network-slicing/operations/unlocks"  Bearer  ${TOKEN}
    ...  -d "{\\"dns\\":[\\"${NETWORK_SLICING_DN}\\"]}"
    Should Contain  ${unlock_request_output}  "status":"ongoing"
    Log  Network slicing UNLOCK request sent, "status":"ongoing". [OK]  console=true
    ${operation_id}  Get Operation Id Value  ${unlock_request_output}
    Set Test Variable  ${OPERATION_ID}
    ${network_slicing_response}  vcu.Get Operate Network Slicing State  ${OPERATION_ID}
    ${message_status}  Run Keyword And Return Status
    ...  Should Not Contain  ${network_slicing_response}  'error_message': 'Get lock unlock MO changes conflict'
    Run Keyword If  ${message_status}==${FALSE}
    ...  Fail  Error message: "Get lock unlock MO changes conflict". [NOK]
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s
    ...  Verify Network Slicing State  ${UNLOCKED}
    Log  Network slicing unlocked successfully. [OK]  console=true


Step 6: Send REST API First Bad LOCK Request
    Log  \nStep 6: Send REST API first bad LOCK request.  console=true
    ${bad_request_output}  Run M2M Command  POST  "https://${VCU_OAM_IP}/api/licensed/v1/network-slicing/operations/locks"  Bearer  ${TOKEN}
    ...  -d "{\\"dns\\":[\\"${NETWORK_SLICING_DN}\\", \\"${CELL_DN}\\"]}"
    Should Contain  ${bad_request_output}  "content":"Incorrect distName"
    Should Contain  ${bad_request_output}  "summary":"Bad Request"
    Log  Command output: "content":"Incorrect distName", "summary":"Bad Request". [OK]  console=true


Step 7: Send REST API Second Bad LOCK Request
    Log  \nStep 7: Send REST API second bad LOCK request.  console=true
    ${bad_request_output}  Run M2M Command  POST  "https://${VCU_OAM_IP}/api/licensed/v1/network-slicing/operations/locks"  Bearer  ${TOKEN}
    ...  -d "{\\"dns\\":[\\"MRBTS-${VCU_MRBTS_ID}/NRBTS-${VCU_NRBTS_ID}/SNSSAI-9\\"]}"
    Should Contain  ${bad_request_output}  "content":"DistName does not exist"
    Should Contain  ${bad_request_output}  "summary":"Bad Request"
    Log  Command output: "content":"DistName does not exist", "summary":"Bad Request". [OK]  console=true


Verify Network Slicing State
    [Arguments]  ${administrative_state}

    ${network_slicing_state}  vcu.Get Network Slicing
    Should Contain  ${administrative_state}  ${network_slicing_state}[0][administrative_state]


Perform Recovery Action
    ${network_slicing}  vcu.Get Network Slicing
    ${network_slicing_status}  Run Keyword And Return Status
    ...  Verify Network Slicing State  ${UNLOCKED}
    ${network_slicing_id}  Create List  ${network_slicing}[0][snssai_id]
    Run Keyword If  ${network_slicing_status}==${FALSE}
    ...  vcu.Unlock Network Slicing  ${network_slicing_id}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s
    ...  Verify Network Slicing State  ${UNLOCKED}
    Log  Recovery action performed. [OK]  console=true


TC Setup
    Common VCU Setup
    Common VDU Setup
    Modify Resource Search Order  WebEM__vCU__Lock_unlock_network_slicing_in_gNB_vCU_by_M2M_interface
    Login Using M2M Interface  ${VCU_OAM_IP}


TC Teardown
    Run Keyword If Test Failed
    ...  Perform Recovery Action
    Logout Using M2M Interface  ${VCU_OAM_IP}
    Common VDU Teardown
    Common VCU Teardown
