*** Settings ***
Documentation
    ...  This TC is created to verify reset operation on vCU cell-group.
    ...  Generate the token and login.
    ...  The request operations that are sent, are: POST, GET, DELETE.
    ...  The reset operation can be made through cell-group dist name.
    ...  Logout with initial token.

Resource  ../../common_resources/M2M_Interface.robot
Resource  ../../common_resources/vcu_frame.robot
Resource  ../../common_resources/vdu_frame.robot


*** Variables ***
${RECOVERY_TIMEOUT}  900s  # Timeout for CBTS to be onAir


*** Keywords ***
TC__WebEM__vCU__Resetting_gNB_vCU_of_cell_groups_by_M2M_interface
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25194
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  06.04.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25194 - Initial TAT creation
    ...  ******************

    Set Tags  CA-WebEM  OWNER-mihnea.spineanu@nokia.com  AUTHOR-anna.benzar@nokia.com  MAINTAINER-anna.benzar@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf
    ...  PHASE-CRT  FEATURE-CB006590

    Step 0: TC Prerequisites
    Step 1: Send REST API Reset Request
    Step 2: Send REST API GET Request
    Step 3: Send REST API DELETE Request
    Step 4: Send REST API Second GET Request


Step 0: TC Prerequisites
    Log  \nStep 0: TC Prerequisites.  console=true
    ${vdu_cell}  vdu.Get Vdu Cell Id
    ${cell_id}  Get Dictionary Keys  ${vdu_cell}[0]
    ${cell_id}  Fetch From Right  ${cell_id}[0]  -
    ${cells_status}  vcu.Get Cells Statuses
    FOR  ${cell_status}  IN  @{cells_status}
        Run Keyword If  ${cell_status}[id] == ${cell_id}
        ...  Run Keywords
        ...  Set Test Variable  ${NR_CELL_GROUP}  ${cell_status}[cell_group_id]
        ...  AND
        ...  Exit For Loop
        ...  ELSE
        ...  Continue For Loop
    END


Step 1: Send REST API Reset Request
    Log  \nStep 1: Send REST API reset request.  console=true
    ${reset_request_output}  Run M2M Command  POST  "https://${VCU_OAM_IP}/api/licensed/v1/cell-groups/operations/resets"  Bearer  ${TOKEN}
    ...  -d "{\\"dn\\":\\"MRBTS-${VCU_MRBTS_ID}/NRBTS-${VCU_NRBTS_ID}/NRCELLGRP-${NR_CELL_GROUP}\\"}"
    Should Contain  ${reset_request_output}  "status" : "ongoing"
    Log  Reset request sent, "status" : "ongoing". [OK]  console=true
    ${operation_id}  Get Operation Id Value With Extra Space  ${reset_request_output}
    Set Test Variable  ${OPERATION_ID}
    Wait Until Keyword Succeeds  300s  10s
    ...  Check All Cells From VDU  operational_state=${DISABLED}  availability_status=${OFFLINE}
    Log  Cells are Disabled and Offline after reset. [OK]  console=true


Step 2: Send REST API GET Request
    Log  \nStep 2: Send REST API GET request.  console=true
    ${get_request_output}  Run M2M Command  GET  "https://${VCU_OAM_IP}:443/api/licensed/v1/cell-groups/operations/resets/${OPERATION_ID}"  Bearer
    ...  ${TOKEN}
    Should Contain  ${get_request_output}  "status" : "ongoing"
    Log  GET request sent, "status" : "ongoing". [OK]  console=true


Step 3: Send REST API DELETE Request
    Log  \nStep 3: Send REST API DELETE request.  console=true
    Run M2M Command  DELETE  "https://${VCU_OAM_IP}:443/api/licensed/v1/cell-groups/operations/resets/${OPERATION_ID}"  Bearer  ${TOKEN}
    Log  DELETE request sent. [OK]  console=true


Step 4: Send REST API Second GET Request
    Log  \nStep 4: Send REST API second GET request.  console=true
    ${get_request_output}  Run M2M Command  GET  "https://${VCU_OAM_IP}/api/licensed/v1/cell-groups/operations/resets/${OPERATION_ID}"  Bearer
    ...  ${TOKEN}
    Should Contain  ${get_request_output}  "content" : "operationId is not found"
    Should Contain  ${get_request_output}  "summary" : "Not Found"
    Log  GET request sent, "summary" : "Not Found". [OK]  console=true
    Log  Waiting for cells to be back Enabled and Online.  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s
    ...  Check All Cells From VDU  operational_state=${ENABLED}  availability_status=${ONLINE}
    Log  Cells are back Enabled and Online. [OK]  console=true


Get Operation Id Value With Extra Space
    [Arguments]  ${request_output}

    ${operation_id}  Should Match Regexp  ${request_output}  "id" : ".*"
    ${operation_id}  Fetch From Right  ${operation_id}  "id" : "
    ${operation_id}  Fetch From Left  ${operation_id}  "

    [Return]  ${operation_id}


TC Setup
    Common VCU Setup
    Common VDU Setup
    Modify Resource Search Order  WebEM__vCU__Resetting_gNB_vCU_of_cell_groups_by_M2M_interface
    Login Using M2M Interface  ${VCU_OAM_IP}


TC Teardown
    Logout Using M2M Interface  ${VCU_OAM_IP}
    Common VDU Teardown
    Common VCU Teardown
