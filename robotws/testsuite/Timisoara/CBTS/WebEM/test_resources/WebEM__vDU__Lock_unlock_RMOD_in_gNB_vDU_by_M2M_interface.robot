*** Settings ***
Documentation
    ...  This TC is created to lock and unlock one RMOD. RMOD is chosen randomly.
    ...  Generate the token and login.
    ...  POST and GET operations are sent.
    ...  Lock RMOD is performed by using its dist name.
    ...  One incorrect unlock request is sent: url contains network-slicing instead of rmods.
    ...  Unlock operation is performed by using RMOD dist name.
    ...  Logout with initial token.

Resource  ../../common_resources/M2M_Interface.robot
Resource  ../../common_resources/vdu_frame.robot


*** Variables ***
${RECOVERY_TIMEOUT}  900s  # Timeout for CBTS to be onAir


*** Keywords ***
TC__WebEM__vDU__Lock_unlock_RMOD_in_gNB_vDU_by_M2M_interface
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25187
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  06.04.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25187 - Initial TAT creation
    ...  ******************

    Set Tags  CA-WebEM  OWNER-mihnea.spineanu@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  FEATURE-CB006590

    Step 0: TC Prerequisites
    Step 1: Send REST API RMOD LOCK Request
    Step 2: Send REST API GET LOCK Request
    Step 3: Send REST API Incorrect Unlock POST Request
    Step 4: Send REST API RMOD UNLOCK Request
    Step 5: Send REST API GET UNLOCK Request


Step 0: TC Prerequisites
    Log  \nStep 0: TC Prerequisites.  console=true
    ${rmods_statuses}  vdu.Get Rmods Status
    ${rmod_distname_list}  Create List
    FOR  ${rmod_status}  IN  @{rmods_statuses}
        Append To List  ${rmod_distname_list}  ${rmod_status}[dist_names][config]
    END
    ${rmod_dn}  Evaluate  random.choice(${rmod_distname_list})  random
    Set Test Variable  ${RMOD_DN}


Step 1: Send REST API RMOD LOCK Request
    Log  \nStep 1: Send REST API RMOD LOCK request.  console=true
    ${lock_request_output}  Run M2M Command  POST  "https://${VDU_OAM_IP}/api/licensed/v1/rmods/operations/locks"  Bearer  ${TOKEN}
    ...  -d "{\\"dns\\":[\\"${RMOD_DN}\\"]}"
    Should Contain  ${lock_request_output}  "status":"ongoing"
    Log  LOCK RMODs request sent, "status":"ongoing". [OK]  console=true
    ${lock_operation_id}  Get Operation Id Value  ${lock_request_output}
    Set Test Variable  ${LOCK_OPERATION_ID}
    Wait Until Keyword Succeeds  300s  10s
    ...  Verify RMODs Parameter From VDU  administrative_state  ${LOCKED}
    Wait Until Keyword Succeeds  300s  10s
    ...  Check All Cells From VDU  operational_state=${DISABLED}
    Log  RMODs locked successfully. [OK]  console=true


Step 2: Send REST API GET LOCK Request
    Log  \nStep 2: Send REST API GET LOCK request.  console=true
    ${get_request_output}  Run M2M Command  GET  "https://${VDU_OAM_IP}/api/licensed/v1/operations/${LOCK_OPERATION_ID}?type=lock_unlock"  Bearer
    ...  ${TOKEN}
    Should Contain  ${get_request_output}  "status":"success"
    Log  GET request sent, "status":"success". [OK]  console=true


Step 3: Send REST API Incorrect Unlock POST Request
    Log  \nStep 3: Send REST API incorrect unlock POST request.  console=true
    ${incorrect_unlock_request_output}  Run M2M Command  POST  "https://${VDU_OAM_IP}/api/licensed/v1/network-slicing/operations/unlocks"  Bearer
    ...  ${TOKEN}  -d "{\\"dns\\":[\\"${RMOD_DN}\\"]}"
    Should Contain  ${incorrect_unlock_request_output}  "content":"Incorrect distName"
    Should Contain  ${incorrect_unlock_request_output}  "summary":"Bad Request"
    Log  Command output: "content":"Incorrect distName", "summary":"Bad Request". [OK]  console=true


Step 4: Send REST API RMOD UNLOCK Request
    Log  \nStep 4: Send REST API RMOD UNLOCK request.  console=true
    ${unlock_request_output}  Run M2M Command  POST  "https://${VDU_OAM_IP}/api/licensed/v1/rmods/operations/unlocks"  Bearer  ${TOKEN}
    ...  -d "{\\"dns\\":[\\"${RMOD_DN}\\"]}"
    Should Contain  ${unlock_request_output}  "status":"ongoing"
    Log  UNLOCK RMODs request sent, "status":"ongoing". [OK]  console=true
    ${unlock_operation_id}  Get Operation Id Value  ${unlock_request_output}
    Set Test Variable  ${UNLOCK_OPERATION_ID}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s
    ...  Verify RMODs Parameter From VDU  administrative_state  ${UNLOCKED}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s
    ...  Check All Cells From VDU  operational_state=${ENABLED}
    Log  RMOD unlocked successfully. [OK]  console=true


Step 5: Send REST API GET UNLOCK Request
    Log  \nStep 5: Send REST API GET UNLOCK request.  console=true
    ${get_request_output}  Run M2M Command  GET
    ...  "https://${VDU_OAM_IP}/api/licensed/v1/rmods/operations/unlocks/${UNLOCK_OPERATION_ID}?type=lock_unlock"  Bearer  ${TOKEN}
    Should Contain  ${get_request_output}  "status":"success"
    Log  GET request sent, "status":"success". [OK]  console=true


Perform Recovery Action
    ${rmod_status}  Run Keyword And Return Status
    ...  Verify RMODs Parameter From VDU  administrative_state  ${LOCKED}
    Run Keyword If  ${rmod_status}
    ...  Step 4: Send REST API RMOD UNLOCK Request
    Log  Recovery action performed. [OK]  console=true


TC Setup
    Common VDU Setup
    Modify Resource Search Order  WebEM__vDU__Lock_unlock_RMOD_in_gNB_vDU_by_M2M_interface
    Login Using M2M Interface  ${VDU_OAM_IP}


TC Teardown
    Run Keyword If Test Failed
    ...  Perform Recovery Action
    Logout Using M2M Interface  ${VDU_OAM_IP}
    Common VDU Teardown
