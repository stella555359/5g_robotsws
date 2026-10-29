*** Settings ***
Documentation
    ...  This TC is created to verify lock and unlock on radio unit.
    ...  Generate the token and login.
    ...  The request operations that are sent are: POST, GET, DELETE.
    ...  Through this requests, lock, unlock, and bad request are performed.
    ...  The lock and unlock operations can be made through rmod dist name.
    ...  Cell dist name is used to send bad request.
    ...  Logout with initial token.

Resource  ../../common_resources/M2M_Interface.robot
Resource  ../../common_resources/vdu_frame.robot


*** Variables ***
${RECOVERY_TIMEOUT}  900s  # Timeout for CBTS to be onAir


*** Keywords ***
TC__WebEM__vDU__Lock_unlock_radio_unit_in_gNB_vDU_by_M2M_interface
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25188
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  06.04.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25188 - Initial TAT creation
    ...  18.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25750 - New KW for checking cells
    ...  ******************

    Set Tags  CA-WebEM  OWNER-mihnea.spineanu@nokia.com  AUTHOR-anna.benzar@nokia.com  MAINTAINER-anna.benzar@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf
    ...  PHASE-CRT  FEATURE-CB006590

    Step 0: TC Prerequisites
    Step 1: Send REST API LOCK Request
    Step 2: Send REST API GET Request
    Step 3: Send REST API DELETE Request
    Step 4: Send REST API Second GET Request
    Step 5: Send REST API UNLOCK Request
    Step 6: Send REST API Bad LOCK Request
    Step 7: Send REST API Bad UNLOCK Request


Step 0: TC Prerequisites
    Log  \nStep 0: TC Prerequisites.  console=true
    ${rmods_status}  Get Rmods Status
    ${chosen_rmod}  Evaluate  random.choice(${rmods_status})  random
    ${rmod_dn}  Set Variable  ${chosen_rmod}[dist_names][config]
    ${cells_status}  Get Vdu Cells Status
    ${chosen_cell}  Evaluate  random.choice(${cells_status})  random
    ${cell_dn}  Set Variable  ${chosen_cell}[dist_names][config]
    Set Test Variable  ${RMOD_DN}
    Set Test Variable  ${CELL_DN}


Step 1: Send REST API LOCK Request
    Log  \nStep 1: Send REST API LOCK request.  console=true
    ${lock_request_output}  Run M2M Command  POST  "https://${VDU_OAM_IP}/api/licensed/v1/rmods/operations/locks"  Bearer  ${TOKEN}
    ...  -d "{\\"dns\\":[\\"${RMOD_DN}\\"]}"
    Should Contain  ${lock_request_output}  "status":"ongoing"
    Log  Lock request sent, "status":"ongoing". [OK]  console=true
    ${operation_id}  Get Operation Id Value  ${lock_request_output}
    Set Test Variable  ${OPERATION_ID}
    Wait Until Keyword Succeeds  300s  10s
    ...  Verify RMODs Parameter From VDU  administrative_state  ${LOCKED}
    Wait Until Keyword Succeeds  300s  10s
    ...  Check All Cells From VDU  operational_state=${DISABLED}
    Log  RMOD is Locked after lock request. [OK]  console=true


Step 2: Send REST API GET Request
    Log  \nStep 2: Send REST API GET request.  console=true
    ${get_request_output}  Run M2M Command  GET  "https://${VDU_OAM_IP}/api/licensed/v1/rmods/operations/locks/${OPERATION_ID}"  Bearer  ${TOKEN}
    Should Contain  ${get_request_output}  "status":"success"
    Log  GET request sent,"status":"success". [OK]  console=true


Step 3: Send REST API DELETE Request
    Log  \nStep 3: Send REST API DELETE request.  console=true
    ${delete_request_output}  Run M2M Command  DELETE  "https://${VDU_OAM_IP}/api/licensed/v1/rmods/operations/locks/${OPERATION_ID}"  Bearer
    ...  ${TOKEN}
    Log  DELETE request sent. [OK]  console=true


Step 4: Send REST API Second GET Request
    Log  \nStep 4: Send REST API second GET request.  console=true
    ${get_request_output}  Run M2M Command  GET  "https://${VDU_OAM_IP}/api/licensed/v1/rmods/operations/locks/${OPERATION_ID}"  Bearer  ${TOKEN}
    Should Contain  ${get_request_output}  "summary":"Get operation failed"
    Log  Second GET request sent, "summary":"Get operation failed". [OK]  console=true


Step 5: Send REST API UNLOCK Request
    Log  \nStep 5: Send REST API UNLOCK request.  console=true
    ${unlock_request_output}  Run M2M Command  POST  "https://${VDU_OAM_IP}/api/licensed/v1/rmods/operations/unlocks"  Bearer  ${TOKEN}
    ...  -d "{\\"dns\\":[\\"${RMOD_DN}\\"]}"
    Should Contain  ${unlock_request_output}  "status":"ongoing"
    Log  Unlock request sent,"status":"ongoing". [OK]  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s
    ...  Verify RMODs Parameter From VDU  administrative_state  ${UNLOCKED}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s
    ...  Check All Cells From VDU  operational_state=${ENABLED}
    Log  RMOD is Unlocked after unlock request. [OK]  console=true


Step 6: Send REST API Bad LOCK Request
    Log  \nStep 6: Send REST API bad LOCK request.  console=true
    ${bad_request_output}  Run M2M Command  POST  "https://${VDU_OAM_IP}/api/licensed/v1/cell-groups/operations/locks"  Bearer  ${TOKEN}
    ...  -d "{\\"ids\\":[\\"${RMOD_DN}\\",\\"${CELL_DN}\\"]}"
    Should Contain  ${bad_request_output}  "content":"Incorrect distName"
    Should Contain  ${bad_request_output}  "summary":"Bad Request"
    Log  Command output: "content":"Incorrect distName", "summary":"Bad Request". [OK]  console=true


Step 7: Send REST API Bad UNLOCK Request
    Log  \nStep 7: Send REST API bad UNLOCK request.  console=true
    ${bad_request_output}  Run M2M Command  POST  "https://${VDU_OAM_IP}/api/licensed/v1/cell-groups/operations/unlocks"  Bearer  ${TOKEN}
    ...  -d "{\\"ids\\":[\\"${RMOD_DN}\\",\\"${CELL_DN}\\"]}"
    Should Contain  ${bad_request_output}  "content":"Incorrect distName"
    Should Contain  ${bad_request_output}  "summary":"Bad Request"
    Log  Command output: "content":"Incorrect distName", "summary":"Bad Request". [OK]  console=true


Perform Recovery Action
    ${cells_status}  Run Keyword And Return Status
    ...  Verify RMODs Parameter From VDU  administrative_state  ${LOCKED}
    Run Keyword If  ${cells_status}
    ...  Step 5: Send REST API UNLOCK Request
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s
    ...  Check All Cells From VDU  operational_state=${ENABLED}
    Log  Recovery action performed!  console=true


TC Setup
    Common VDU Setup
    Modify Resource Search Order  WebEM__vDU__Lock_unlock_radio_unit_in_gNB_vDU_by_M2M_interface
    Login Using M2M Interface  ${VDU_OAM_IP}


TC Teardown
    Run Keyword If Test Failed
    ...  Perform Recovery Action
    Logout Using M2M Interface  ${VDU_OAM_IP}
    Common VDU Teardown
