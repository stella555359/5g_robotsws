*** Settings ***
Documentation
    ...  This TC is created to verify lock and unlock DU from vCU.
    ...  Generate the token and login.
    ...  The request operations that are sent are: POST, GET, DELETE.
    ...  Through this requests, lock and unlock are performed.
    ...  The lock and unlock operations can be made through dist name or directly through du id.
    ...  Logout with initial token.

Resource  ../../common_resources/M2M_Interface.robot
Resource  ../../common_resources/vcu_frame.robot
Resource  ../../common_resources/vdu_frame.robot


*** Variables ***
${RECOVERY_TIMEOUT}  900s  # Timeout for CBTS to be onAir


*** Keywords ***
TC__WebEM__vCU__Lock_Unlock_DUs_in_gNB_vCU_by_M2M_interface
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25192
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  13.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25192 - Initial TAT creation
    ...  ******************

    Set Tags  CA-WebEM  OWNER-mihnea.spineanu@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  FEATURE-CB006590

    Step1: Send Lock And Get Requests For DU With Distname
    Step2: Send Delete And Get Requests For DU With Distname
    Step3: Send Unlock And Get Requests For DU With Distname
    Step4: Send Delete And Get Requests After Unlock For DU With Distname
    Step5: Send Lock And Get Requests For DU With DU Id
    Step6: Send Delete And Get Requests For DU With DU Id
    Step7: Send Unlock And Get Requests For DU With DU Id
    Step8: Send Delete And Get Requests For DU With DU Id


Step1: Send Lock And Get Requests For DU With Distname
    Log  \nStep1: Send lock and get requests for DU with distname  console=true
    ${lock_request_output}  Run M2M Command  POST  "https://${VCU_OAM_IP}/api/licensed/v1/dus/operations/locks"  Bearer  ${TOKEN}
    ...  -d "{\\"ids\\":[\\"MRBTS-${VCU_MRBTS_ID}/NRBTS-${VCU_NRBTS_ID}/NRDU-${VDU_ID}\\"]}"
    Should Contain  ${lock_request_output}  "status":"ongoing"
    Log  Lock request sent, "status":"ongoing"![OK]  console=true
    ${operation_id_lock_dn}  Get Operation Id Value  ${lock_request_output}
    Set Test Variable  ${OPERATION_ID_LOCK_DN}
    Wait Until Keyword Succeeds  300s  10s
    ...  Check All Cells From VDU  operational_state=${DISABLED}
    Log  The cells are Disabled after lock request![OK]  console=true
    Run GET Request And Verify Status For DU From VCU  locks  ${OPERATION_ID_LOCK_DN}


Step2: Send Delete And Get Requests For DU With Distname
    Log  \nStep2: Send delete and get requests for DU with distname  console=true
    Run Delete And Get Commands For DU From VCU  locks  ${OPERATION_ID_LOCK_DN}


Step3: Send Unlock And Get Requests For DU With Distname
    Log  \nStep3: Send unlock and get requests for DU with distname  console=true
    ${unlock_request_output}  Run M2M Command  POST  "https://${VCU_OAM_IP}/api/licensed/v1/dus/operations/unlocks"  Bearer  ${TOKEN}
    ...  -d "{\\"ids\\":[\\"MRBTS-${VCU_MRBTS_ID}/NRBTS-${VCU_NRBTS_ID}/NRDU-${VDU_ID}\\"]}"
    Should Contain  ${unlock_request_output}  "status":"ongoing"
    Log  Unlock request sent,"status":"ongoing"![OK]  console=true
    ${operation_id_unlock_dn}  Get Operation Id Value  ${unlock_request_output}
    Set Test Variable  ${OPERATION_ID_UNLOCK_DN}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s
    ...  Check All Cells From VDU  administrative_state=${UNLOCKED}  operational_state=${ENABLED}
    Log  The cells are Unlocked and Enabled after unlock request![OK]  console=true
    Run GET Request And Verify Status For DU From VCU  unlocks  ${OPERATION_ID_UNLOCK_DN}


Step4: Send Delete And Get Requests After Unlock For DU With Distname
    Log  \nStep4: Send delete and get requests after unlock for DU with distname  console=true
    Run Delete And Get Commands For DU From VCU  unlocks  ${OPERATION_ID_UNLOCK_DN}


Step5: Send Lock And Get Requests For DU With DU Id
    Log  \nStep5: Send lock and get requests for DU with DU id  console=true
    ${lock_request_output}  Run M2M Command  POST  "https://${VCU_OAM_IP}/api/licensed/v1/dus/operations/locks"  Bearer  ${TOKEN}
    ...  -d "{\\"ids\\":[\\"${VDU_ID}\\"]}"
    Should Contain  ${lock_request_output}  "status":"ongoing"
    Log  Lock request sent through DU id: "status":"ongoing"![OK]  console=true
    ${operation_id_lock}  Get Operation Id Value  ${lock_request_output}
    Set Test Variable  ${OPERATION_ID_LOCK}
    Wait Until Keyword Succeeds  300s  10s
    ...  Check All Cells From VDU  operational_state=${DISABLED}
    Log  The cells are Disabled after lock request![OK]  console=true
    Run GET Request And Verify Status For DU From VCU  locks  ${OPERATION_ID_LOCK}


Step6: Send Delete And Get Requests For DU With DU Id
    Log  \nStep6: Send delete and get requests for DU with DU id  console=true
    Run Delete And Get Commands For DU From VCU  locks  ${OPERATION_ID_LOCK}


Step7: Send Unlock And Get Requests For DU With DU Id
    Log  \nStep7: Send unlock and get requests for DU with DU id  console=true
    ${unlock_request_output}  Run M2M Command  POST  "https://${VCU_OAM_IP}/api/licensed/v1/dus/operations/unlocks"  Bearer  ${TOKEN}
    ...  -d "{\\"ids\\":[\\"${VDU_ID}\\"]}"
    Should Contain  ${unlock_request_output}  "status":"ongoing"
    Log  Unlock request sent through DU id: "status":"ongoing"![OK]  console=true
    ${operation_id_unlock}  Get Operation Id Value  ${unlock_request_output}
    Set Test Variable  ${OPERATION_ID_UNLOCK}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s
    ...  Check All Cells From VDU  administrative_state=${UNLOCKED}  operational_state=${ENABLED}
    Log  The cells are Unlocked and Enabled after unlock request sent through DU id![OK]  console=true
    Run GET Request And Verify Status For DU From VCU  unlocks  ${OPERATION_ID_UNLOCK}


Step8: Send Delete And Get Requests For DU With DU Id
    Log  \nStep8: Send delete and get requests for DU with DU id  console=true
    Run Delete And Get Commands For DU From VCU  unlocks  ${OPERATION_ID_UNLOCK}


Run Delete And Get Commands For DU From VCU
    [Arguments]  ${action}  ${operation_id}

    Run M2M Command  DELETE  "https://${VCU_OAM_IP}/api/licensed/v1/dus/operations/${action}/${operation_id}"  Bearer  ${TOKEN}
    Log  DELETE request sent. [OK]  console=true
    ${get_request_output}  Run M2M Command  GET  "https://${VCU_OAM_IP}/api/licensed/v1/dus/operations/${action}/${operation_id}"  Bearer  ${TOKEN}
    Should Contain  ${get_request_output}  "summary":"Get operation failed"
    Log  Second GET request sent, "summary":"Get operation failed"![OK]  console=true


Run GET Request And Verify Status For DU From VCU
    [Arguments]  ${action}  ${operation_id}

    ${get_request_output}  Run M2M Command  GET  "https://${VCU_OAM_IP}/api/licensed/v1/dus/operations/${action}/${operation_id}"  Bearer  ${TOKEN}
    Should Contain  ${get_request_output}  "status":"success"
    Log  GET request sent,"status":"success"![OK]  console=true


Perform Recovery Action To Unlock DU
    Log  Perform recovery action to unlock DU  console=true
    ${cells_status}  Run Keyword And Return Status
    ...  Check The Specific Cell From VCU  ${CELL_ID}  operational_state=${DISABLED}
    Run Keyword If  ${cells_status}
    ...  Recovery Action To Unlock DU


Recovery Action To Unlock DU
    Run M2M Command  POST  "https://${VCU_OAM_IP}/api/licensed/v1/dus/operations/unlocks"  Bearer  ${TOKEN}
    ...  -d "{\\"ids\\":[\\"MRBTS-${VCU_MRBTS_ID}/NRBTS-${VCU_NRBTS_ID}/NRDU-${VDU_ID}\\"]}"
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s
    ...  Check All Cells From VDU  administrative_state=${UNLOCKED}  operational_state=${ENABLED}
    Log  All cells are Unlocked and Enabled after unlock request![OK]  console=true


TC Setup
    Common VDU Setup
    Common VCU Setup
    Modify Resource Search Order  WebEM__vCU__Lock_Unlock_DUs_in_gNB_vCU_by_M2M_interface
    Login Using M2M Interface  ${VCU_OAM_IP}


TC Teardown
    Run Keyword If Test Failed
    ...  Perform Recovery Action To Unlock DU
    Logout Using M2M Interface  ${VCU_OAM_IP}
    Common VCU Teardown
    Common VDU Teardown
