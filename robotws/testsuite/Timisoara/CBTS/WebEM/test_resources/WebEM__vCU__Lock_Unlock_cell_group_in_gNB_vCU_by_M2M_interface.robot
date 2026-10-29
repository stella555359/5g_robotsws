*** Settings ***
Documentation
    ...  This TC is created to verify lock and unlock cell group behaviour on vCU.
    ...  Generate the token and login.
    ...  The request operations that are sent are: POST, GET, DELETE.
    ...  Through this requests, lock, unlock, and bad request are performed.
    ...  The lock and unlock operations can be made through dist name or directly through cell group id.
    ...  Logout with initial token.

Resource  ../../common_resources/M2M_Interface.robot
Resource  ../../common_resources/vcu_frame.robot
Resource  ../../common_resources/vdu_frame.robot


*** Variables ***
${RECOVERY_TIMEOUT}  900s  # Timeout for CBTS to be onAir


*** Keywords ***
TC__WebEM__vCU__Lock_Unlock_cell_group_in_gNB_vCU_by_M2M_interface
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25193
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  11.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25193 - Initial TAT creation
    ...  18.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25750 - New KW for checking cells
    ...  ******************

    Set Tags  CA-WebEM  OWNER-mihnea.spineanu@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  FEATURE-CB006590

    Step0: TC Prerequisites
    Step1: Send Lock And Get Requests With Distname
    Step2: Send Delete And Get Requests With Distname
    Step3: Send Unlock And Get Requests With Distname
    Step4: Send Delete And Get Requests After Unlock With Distname
    Step5: Send Bad Request
    Step6: Send Lock And Get Requests With Cellgroup Id
    Step7: Send Delete And Get Requests With Cellgroup Id
    Step8: Send Unlock And Get Requests With Cellgroup Id
    Step9: Send Delete And Get Requests With Cellgroup Id


Step0: TC Prerequisites
    Log  \nStep0: TC Prerequisites  console=true
    ${vcu_cells}  vdu.Get Vdu Cell Id
    ${cell_dictionary}  Evaluate  random.choice(${vcu_cells})  random
    ${cell_id}  Get Dictionary Keys  ${cell_dictionary}
    ${cell_id}  Fetch From Right  ${cell_id}[0]  -
    Set Test Variable  ${CELL_ID}
    ${cells_status}  vcu.Get Cells Statuses
    FOR  ${cell_status}  IN  @{cells_status}
        Run Keyword If  ${cell_status}[id] == ${CELL_ID}
        ...  Run Keywords
        ...  Set Test Variable  ${NR_CELL_GROUP}  ${cell_status}[cell_group_id]
        ...  AND
        ...  Exit For Loop
        ...  ELSE
        ...  Continue For Loop
    END


Step1: Send Lock And Get Requests With Distname
    Log  \nStep1: Send lock and get requests with distname  console=true
    ${lock_request_output}  Run M2M Command  POST  "https://${VCU_OAM_IP}/api/licensed/v1/cell-groups/operations/locks"  Bearer  ${TOKEN}
    ...  -d "{\\"ids\\":[\\"MRBTS-${VCU_MRBTS_ID}/NRBTS-${VCU_NRBTS_ID}/NRCELLGRP-${NR_CELL_GROUP}\\"]}"
    Should Contain  ${lock_request_output}  "status":"ongoing"
    Log  Lock request sent, "status":"ongoing"![OK]  console=true
    ${operation_id_lock_dn}  Get Operation Id Value  ${lock_request_output}
    Set Test Variable  ${OPERATION_ID_LOCK_DN}
    Wait Until Keyword Succeeds  300s  10s
    ...  Check The Specific Cell From VCU  ${CELL_ID}  administrative_state=${LOCKED}  operational_state=${DISABLED}
    Log  The cell is Locked and Disabled after lock request![OK]  console=true
    Run GET Request And Verify Status For VCU  locks  ${OPERATION_ID_LOCK_DN}


Step2: Send Delete And Get Requests With Distname
    Log  \nStep2: Send delete and get requests with distname  console=true
    Run Delete And Get Commands For Cell Group From VCU  locks  ${OPERATION_ID_LOCK_DN}


Step3: Send Unlock And Get Requests With Distname
    Log  \nStep3: Send unlock and get requests with distname  console=true
    ${unlock_request_output}  Run M2M Command  POST  "https://${VCU_OAM_IP}/api/licensed/v1/cell-groups/operations/unlocks"  Bearer  ${TOKEN}
    ...  -d "{\\"ids\\":[\\"MRBTS-${VCU_MRBTS_ID}/NRBTS-${VCU_NRBTS_ID}/NRCELLGRP-${NR_CELL_GROUP}\\"]}"
    Should Contain  ${unlock_request_output}  "status":"ongoing"
    Log  Unlock request sent,"status":"ongoing"![OK]  console=true
    ${operation_id_unlock_dn}  Get Operation Id Value  ${unlock_request_output}
    Set Test Variable  ${OPERATION_ID_UNLOCK_DN}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s
    ...  Check The Specific Cell From VCU  ${CELL_ID}  administrative_state=${UNLOCKED}  operational_state=${ENABLED}
    Log  The cell is Unlocked and Enabled after unlock request![OK]  console=true
    Run GET Request And Verify Status For VCU  unlocks  ${OPERATION_ID_UNLOCK_DN}


Step4: Send Delete And Get Requests After Unlock With Distname
    Log  \nStep4: Send delete and get requests after unlock with distname  console=true
    Run Delete And Get Commands For Cell Group From VCU  unlocks  ${OPERATION_ID_UNLOCK_DN}


Step5: Send Bad Request
    Log  \nStep5: Send bad request  console=true
    ${dist_name}  Catenate  SEPARATOR=  -d "{\\"ids\\":[\\"MRBTS-${VCU_MRBTS_ID}/NRBTS-${VCU_NRBTS_ID}/NRCELL-${CELL_ID}\\",
    ...  \\"MRBTS-${VCU_MRBTS_ID}/NRBTS-${VCU_NRBTS_ID}/NRCELLGRP-${NR_CELL_GROUP}\\"]}"
    ${bad_request_output}  Run M2M Command  POST  "https://${VCU_OAM_IP}/api/licensed/v1/cell-groups/operations/locks"  Bearer  ${TOKEN}
    ...  ${dist_name}
    Should Contain  ${bad_request_output}  "content":"Incorrect distName"
    Should Contain  ${bad_request_output}  "summary":"Bad Request"
    Log  Command output: "content":"Incorrect distName", "summary":"Bad Request"![OK]  console=true


Step6: Send Lock And Get Requests With Cellgroup Id
    Log  \nStep6: Send lock and get requests with cellgroup id  console=true
    ${lock_request_output}  Run M2M Command  POST  "https://${VCU_OAM_IP}/api/licensed/v1/cell-groups/operations/locks"  Bearer  ${TOKEN}
    ...  -d "{\\"ids\\":[\\"${CELL_ID}\\"]}"
    Should Contain  ${lock_request_output}  "status":"ongoing"
    Log  Lock request sent through cellgroup id: "status":"ongoing"![OK]  console=true
    ${operation_id_lock}  Get Operation Id Value  ${lock_request_output}
    Set Test Variable  ${OPERATION_ID_LOCK}
    Wait Until Keyword Succeeds  300s  10s
    ...  Check The Specific Cell From VCU  ${CELL_ID}  administrative_state=${LOCKED}  operational_state=${DISABLED}
    Log  The cell is Locked and Disabled after lock request sent through cellgroup id![OK]  console=true
    Run GET Request And Verify Status For VCU  locks  ${OPERATION_ID_LOCK}


Step7: Send Delete And Get Requests With Cellgroup Id
    Log  \nStep7: Send delete and get requests with cellgroup id  console=true
    Run Delete And Get Commands For Cell Group From VCU  locks  ${OPERATION_ID_LOCK}


Step8: Send Unlock And Get Requests With Cellgroup Id
    Log  \nStep8: Send unlock and get requests with cellgroup id  console=true
    ${unlock_request_output}  Run M2M Command  POST  "https://${VCU_OAM_IP}/api/licensed/v1/cell-groups/operations/unlocks"  Bearer  ${TOKEN}
    ...  -d "{\\"ids\\":[\\"${CELL_ID}\\"]}"
    Should Contain  ${unlock_request_output}  "status":"ongoing"
    Log  Unlock request sent through cellgroup id: "status":"ongoing"![OK]  console=true
    ${operation_id_unlock}  Get Operation Id Value  ${unlock_request_output}
    Set Test Variable  ${OPERATION_ID_UNLOCK}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s
    ...  Check The Specific Cell From VCU  ${CELL_ID}  administrative_state=${UNLOCKED}  operational_state=${ENABLED}
    Log  The cell is Unlocked and Enabled after unlock request sent through cellgroup id![OK]  console=true
    Run GET Request And Verify Status For VCU  unlocks  ${OPERATION_ID_UNLOCK}


Step9: Send Delete And Get Requests With Cellgroup Id
    Log  \nStep9: Send delete and get requests with cellgroup id  console=true
    Run Delete And Get Commands For Cell Group From VCU  unlocks  ${OPERATION_ID_UNLOCK}


Run Delete And Get Commands For Cell Group From VCU
    [Arguments]  ${action}  ${operation_id}

    Run M2M Command  DELETE  "https://${VCU_OAM_IP}/api/licensed/v1/cell-groups/operations/${action}/${operation_id}"  Bearer  ${TOKEN}
    Log  DELETE request sent. [OK]  console=true
    ${get_request_output}  Run M2M Command  GET  "https://${VCU_OAM_IP}/api/licensed/v1/cell-groups/operations/${action}/${operation_id}"  Bearer
    ...  ${TOKEN}
    Should Contain  ${get_request_output}  "summary":"Get operation failed"
    Log  Second GET request sent, "summary":"Get operation failed"![OK]  console=true


Run GET Request And Verify Status For VCU
    [Arguments]  ${action}  ${operation_id}

    ${get_request_output}  Run M2M Command  GET  "https://${VCU_OAM_IP}/api/licensed/v1/cell-groups/operations/${action}/${operation_id}"  Bearer
    ...  ${TOKEN}
    Should Contain  ${get_request_output}  "status":"success"
    Log  GET request sent,"status":"success"![OK]  console=true


Perform Recovery Action
    Log  Perform recovery action  console=true
    ${cells_status}  Run Keyword And Return Status
    ...  Check The Specific Cell From VCU  ${CELL_ID}  administrative_state=${LOCKED}
    Run Keyword If  ${cells_status}
    ...  Recovery Action


Recovery Action
    Run M2M Command  POST  "https://${VCU_OAM_IP}/api/licensed/v1/cell-groups/operations/unlocks"  Bearer  ${TOKEN}
    ...  -d "{\\"ids\\":[\\"MRBTS-${VCU_MRBTS_ID}/NRBTS-${VCU_NRBTS_ID}/NRCELLGRP-${NR_CELL_GROUP}\\"]}"
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s
    ...  Check The Specific Cell From VCU  ${CELL_ID}  administrative_state=${UNLOCKED}  operational_state=${ENABLED}
    Log  The cell is Unlocked and Enabled after unlock request![OK]  console=true


TC Setup
    Common VDU Setup
    Common VCU Setup
    Modify Resource Search Order  WebEM__vCU__Lock_Unlock_cell_group_in_gNB_vCU_by_M2M_interface
    Login Using M2M Interface  ${VCU_OAM_IP}


TC Teardown
    Run Keyword If Test Failed
    ...  Perform Recovery Action
    Logout Using M2M Interface  ${VCU_OAM_IP}
    Common VCU Teardown
    Common VDU Teardown
