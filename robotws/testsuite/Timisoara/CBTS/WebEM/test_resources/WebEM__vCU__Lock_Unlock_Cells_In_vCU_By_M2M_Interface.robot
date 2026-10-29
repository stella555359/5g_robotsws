*** Settings ***
Documentation
    ...  This TC is created to test different lock/unlock commands issued through M2M interface and the vCU response.
    ...  Generate the token and login.
    ...  Lock, unlock and bad requests are performed through distName, cell group id or on all cells.
    ...  Logout with initial token.

Resource  ../../common_resources/M2M_Interface.robot
Resource  ../../common_resources/vcu_frame.robot
Resource  ../../common_resources/vcu_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}  900s  # Timeout for CBTS to be onAir


*** Keywords ***
TC__WebEM__vCU__Lock_Unlock_Cells_In_vCU_By_M2M_Interface
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25191
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 06.04.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25191 - Initial TAT creation

    Set Tags  CA-WebEM  OWNER-mihnea.spineanu@nokia.com  AUTHOR-victor.banicioiu@nokia.com  MAINTAINER-victor.banicioiu@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS23  FEATURE-CB006590-CR-M-B3

    Step 0: Collect VCU Cells Data
    Step 1: Send Rest API LOCK Command
    Step 2: Send Rest API UNLOCK Command
    Step 3: Send Rest API LOCK Command Through Cell DistName
    Step 4: Send Rest API GET Command
    Step 5: Send Rest API DELETE Command
    Step 6: Send Second Rest API GET Command
    Step 7: Send Rest API UNLOCK Command Through Cell DistName
    Step 8: Send Rest API BAD LOCK Command
    Step 9: Send Rest API LOCK Command Through Cell Id
    Step 10: Send Rest API UNLOCK Command Through Cell Id
    Step 11: Send Third Rest API GET Command
    Step 12: Send Second Rest API DELETE Command
    Step 13: Send Fourth Rest API GET Command


Step 0: Collect VCU Cells Data
    Log  \nStep 0: Collect vCU cells data  console=true
    ${vcu_cells_data}  Get Cells Statuses
    ${cell_dictionary}  Evaluate  random.choice(${vcu_cells_data})  random
    ${dist_names_dict}  Set Variable  ${cell_dictionary}[dist_names]
    ${dist_name}  Get Dictionary Values  ${dist_names_dict}
    ${config_dist_name}  Split String  ${dist_name}[0]  /
    ${cell_id}  Fetch From Right  ${dist_name}[0]  -
    Set Test Variable  ${DIST_NAME}  ${dist_name}[0]
    Set Test Variable  ${CELL_ID}


Step 1: Send Rest API Lock Command
    Log  \nStep 1: Send Rest API lock command  console=true
    ${lock_all_request_response}  Run M2M Command  POST  "https://${VCU_OAM_IP}/api/licensed/v1/cells/operations/locks"  Bearer  ${TOKEN}
    ...  -d "{\\"ids\\":[\\"all\\"]}"
    Should Contain  ${lock_all_request_response}  "status":"ongoing"
    Log  Lock request sent for all cells: "status":"ongoing". [OK]  console=true
    Wait Until Keyword Succeeds  300s  10s
    ...  Check All Cells From VCU  administrative_state=${LOCKED}  operational_state=${DISABLED}
    Log  Cells are Locked and Disabled after lock request. [OK]  console=true


Step 2: Send Rest API UNLOCK Command
    Log  \nStep 2: Send Rest API UNLOCK command  console=true
    Unlock All Cells


Step 3: Send Rest API LOCK Command Through Cell DistName
    Log  \nStep 3: Send Rest API LOCK command through cell distName  console=true
    ${lock_dist_name_response}  Run M2M Command  POST  "https://${VCU_OAM_IP}/api/licensed/v1/cells/operations/locks"  Bearer  ${TOKEN}
    ...  -d "{\\"ids\\":[\\"${DIST_NAME}\\"]}"
    Should Contain  ${lock_dist_name_response}  "status":"ongoing"
    Log  Lock request sent for cell with distName: ${DIST_NAME}: "status":"ongoing". [OK]  console=true
    ${operation_id}  Get Operation Id Value  ${lock_dist_name_response}
    Set Test Variable  ${OPERATION_ID}
    Wait Until Keyword Succeeds  300s  10s
    ...  Check The Specific Cell From VCU  ${CELL_ID}  administrative_state=${LOCKED}  operational_state=${DISABLED}
    Log  Cell ${DIST_NAME} is Locked and Disabled after lock request. [OK]  console=true


Step 4: Send Rest API GET Command
    Log  \nStep 4: Send Rest API GET command  console=true
    Run Successful GET API Request  locks


Step 5: Send Rest API DELETE Command
    Log  \nStep 5: Send Rest API DELETE command  console=true
    ${delete_request_output}  Run M2M Command  DELETE  "https://${VCU_OAM_IP}/api/licensed/v1/cells/operations/locks/${OPERATION_ID}"  Bearer
    ...  ${TOKEN}
    Log  Delete request sent. [OK]  console=true


Step 6: Send Second Rest API GET Command
    Log  \nStep 6: Send second Rest API GET command  console=true
    Run Failed GET API Request  locks


Step 7: Send Rest API UNLOCK Command Through Cell DistName
    Log  \nStep 7: Send Rest API UNLOCK command through cell distName  console=true
    Unlock Cell By Distname


Step 8: Send Rest API BAD LOCK Command
    Log  \nStep 8: Send Rest API BAD LOCK command  console=true
    ${bad_request}  Catenate  SEPARATOR=  -d "{\\"ids\\":[\\"${DIST_NAME}\\",  \\"${CELL_ID}\\"]}"
    ${bad_lock_response}  Run M2M Command  POST  "https://${VCU_OAM_IP}/api/licensed/v1/cells/operations/locks"  Bearer  ${TOKEN}  ${bad_request}
    Should Contain  ${bad_lock_response}  "content":"Mixed format not allowed"
    Should Contain  ${bad_lock_response}  "summary":"Bad Request"
    Log  Command output: "content":"Mixed format not allowed", "summary":"Bad Request". [OK]  console=true


Step 9: Send Rest API LOCK Command Through Cell Id
    Log  \nStep 9: Send Rest API LOCK command through cell id  console=true
    ${lock_cellid_response}  Run M2M Command  POST  "https://${VCU_OAM_IP}/api/licensed/v1/cells/operations/locks"  Bearer  ${TOKEN}
    ...  -d "{\\"ids\\":[\\"${CELL_ID}\\"]}"
    Should Contain  ${lock_cellid_response}  "status":"ongoing"
    Log  Lock request sent for cell with id: ${CELL_ID}: "status":"ongoing". [OK]  console=true
    ${operation_id}  Get Operation Id Value  ${lock_cellid_response}
    Set Test Variable  ${OPERATION_ID}
    Wait Until Keyword Succeeds  300s  10s
    ...  Check The Specific Cell From VCU  ${CELL_ID}  administrative_state=${LOCKED}  operational_state=${DISABLED}
    Log  Cell with id ${CELL_ID} is Locked and Disabled after lock request. [OK]  console=true


Step 10: Send Rest API UNLOCK Command Through Cell Id
    Log  \nStep 10: Send Rest API UNLOCK command through cell id  console=true
    ${unlock_cellid_response}  Run M2M Command  POST  "https://${VCU_OAM_IP}/api/licensed/v1/cells/operations/unlocks"  Bearer  ${TOKEN}
    ...  -d "{\\"ids\\":[\\"${CELL_ID}\\"]}"
    Should Contain  ${unlock_cellid_response}  "status":"ongoing"
    Log  Unlock request sent for cell with id: ${CELL_ID}: "status":"ongoing". [OK]  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s
    ...  Check The Specific Cell From VCU  ${CELL_ID}  administrative_state=${UNLOCKED}  operational_state=${ENABLED}
    Log  Cell with id ${CELL_ID} is Unlocked and Enabled after unlock request. [OK]  console=true


Step 11: Send Third Rest API GET Command
    Log  \nStep 11: Send third Rest API GET command  console=true
    Run Successful GET API Request  unlocks


Step 12: Send Second Rest API DELETE Command
    Log  \nStep 12: Send second Rest API DELETE command  console=true
    ${delete_request_output}  Run M2M Command  DELETE  "https://${VCU_OAM_IP}/api/licensed/v1/cells/operations/unlocks/${OPERATION_ID}"  Bearer
    ...  ${TOKEN}
    Log  Delete request sent. [OK]  console=true


Step 13: Send Fourth Rest API GET Command
    Log  \nStep 13: Send fourth Rest API GET command  console=true
    Run Failed GET API Request  unlocks


Run Successful GET API Request
    [Arguments]  ${operation_type}

    ${get_request_output}  Run M2M Command  GET  "https://${VCU_OAM_IP}/api/licensed/v1/cells/operations/${operation_type}/${OPERATION_ID}"  Bearer
    ...  ${TOKEN}
    Should Contain  ${get_request_output}  "status":"success"
    Log  GET request sent,"status":"success". [OK]  console=true


Run Failed GET API Request
    [Arguments]  ${operation_type}

    ${get_request_output}  Run M2M Command  GET  "https://${VCU_OAM_IP}/api/licensed/v1/cells/operations/${operation_type}/${OPERATION_ID}"  Bearer
    ...  ${TOKEN}
    Should Contain  ${get_request_output}  "summary":"Get operation failed"
    Log  GET request sent, "summary":"Get operation failed". [OK]  console=true


Perform Recovery Action
    ${cells_status}  Run Keyword And Return Status
    ...  Check All Cells From VCU  administrative_state=${LOCKED}  operational_state=${DISABLED}
    ${cell_status}  Run Keyword And Return Status
    ...  Check The Specific Cell From VCU  ${CELL_ID}  administrative_state=${LOCKED}  operational_state=${DISABLED}
    Run Keyword If  ${cells_status}
    ...  Unlock All Cells
    ...  ELSE IF  ${cell_status}
    ...  Unlock Cell By Distname


Unlock All Cells
    ${unlock_request_response}  Run M2M Command  POST  "https://${VCU_OAM_IP}/api/licensed/v1/cells/operations/unlocks"  Bearer  ${TOKEN}
    ...  -d "{\\"ids\\":[\\"all\\"]}"
    Should Contain  ${unlock_request_response}  "status":"ongoing"
    Log  Unlock request sent for all cells, "status":"ongoing". [OK]  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s
    ...  Check All Cells From VCU  administrative_state=${UNLOCKED}  operational_state=${ENABLED}
    Log  Cells are Unlocked and Enabled after unlock request. [OK]  console=true


Unlock Cell By Distname
    ${unlock_request_response}  Run M2M Command  POST  "https://${VCU_OAM_IP}/api/licensed/v1/cells/operations/unlocks"  Bearer  ${TOKEN}
    ...  -d "{\\"ids\\":[\\"${DIST_NAME}\\"]}"
    Should Contain  ${unlock_request_response}  "status":"ongoing"
    Log  Unlock request sent for cell with distName: ${DIST_NAME}: "status":"ongoing". [OK]  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s
    ...  Check The Specific Cell From VCU  ${CELL_ID}  administrative_state=${UNLOCKED}  operational_state=${ENABLED}
    Log  Cell ${DIST_NAME} is Unlocked and Enabled after unlock request. [OK]  console=true


TC Setup
    Common VCU Setup
    Modify Resource Search Order  WebEM__vCU__Lock_Unlock_Cells_In_vCU_By_M2M_Interface
    Login Using M2M Interface  ${VCU_OAM_IP}


TC Teardown
    Run Keyword If Test Failed
    ...  Perform Recovery Action
    Logout Using M2M Interface  ${VCU_OAM_IP}
    Common VCU Teardown
