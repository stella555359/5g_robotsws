*** Settings ***
Documentation
    ...  This TC is created to verify Diagnostic check through M2M interface.
    ...  Diagnostic check is requested and files are checked.
    ...  currentPlanForRestart is deleted and Diagnostic check is requested again.
    ...  fault 4681 is verified to be present in WebEM.
    ...  vCU reset is performed and fault must be cleared.

Library  ../../common_resources/python_resources/csv_resource.py
Resource  ../../common_resources/M2M_Interface.robot
Resource  ../../common_resources/vdu_frame.robot


*** Variables ***
${RESTORE_TIMEOUT}  15m  # Timeout for vDU to recover after SCF upload


*** Keywords ***
TC__WebEM__vDU__Run_Configuration_Validation_from_WebEM_Cloud_M2M_Interface
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27190
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  25.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27190 - Initial TAT creation
    ...  09.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29831 - Change method of retrieving pod and container name
    ...  ******************

    Set Tags  CA-WebEM  OWNER-marius.stanescu@nokia.com  MAINTAINER-anna.benzar@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  FEATURE-CB009129


    Step1: Request Full Diagnostic Check Through M2M Interface
    Step2: Open Ssh Connection To VDU And Check Diagnostic Files - WebEM Remote Tool
    Step3: Delete Diagnostic Request
    Step4: Delete currentPlanForRestart.Bak File From VDU
    Step5: Request Full Diagnostic Check Through M2M Interface
    Step6: Verify Diagnostic Check Alarm To Appear
    Step7: Delete Diagnostic Request
    Step8: Reset VDU And Check If Alarm Is Cleared


Step${index}: Request Full Diagnostic Check Through M2M Interface
    Log  \nStep${index}: Start Diagnostic Check through NMS.  console=true
    ${current_date_time}  Get Current Time For Diagnostic Check
    Set Test Variable  ${CURRENT_DATE_TIME}
    ${diagnostic_post_output}  Run M2M Command  POST  "https://${VDU_OAM_IP}/api/licensed/v1/diagnostic-checks/operations/launches"  Bearer  ${TOKEN}
    ...  -d "{\\"allowServiceImpact\\":true}"
    Should Contain  ${diagnostic_post_output}  "status":"ongoing"
    Log  Diagnostic POST request sent, "status":"ongoing"! [OK]  console=true
    ${diagnostic_op_id}  Get Operation Id Value - Longer Version  ${diagnostic_post_output}
    Set Test Variable  ${DIAGNOSTIC_OP_ID}
    Sleep  10s  Wait for Diagnostic check to be done.
    ${diagnostic_get_output}  Run M2M Command  GET  "https://${VDU_OAM_IP}/api/licensed/v1/diagnostic-checks/operations/launches/${DIAGNOSTIC_OP_ID}"
    ...  Bearer  ${TOKEN}
    Should Contain  ${diagnostic_get_output}  "status":"succeeded"
    Log  Diagnostic GET request sent, "status":"succeeded"! [OK]  console=true


Step${index}: Open Ssh Connection To VDU And Check Diagnostic Files - ${type}
    Log  \nStep${index}: Open ssh connection to vDU and check Diagnostic files.  console=true
    Open Connection To VDU And Bring Diagnostic Files To Local Machine  cran1  oamcm  ${index}
    ${csv_content}  Return Csv File Content  ${TEST_RESULTS_DIR}/Diagnostic_Check_step_${index}/DiagnosticReport.csv
    Verify first row in DiagnosticReport.Csv File  ${csv_content}
    Verify second row in DiagnosticReport.Csv File  ${csv_content}  ${VDU_MRBTS_ID}  ${type}  OK  ${CURRENT_DATE_TIME}
    Verify third row in DiagnosticReport.Csv File  ${csv_content}  ${VDU_MRBTS_ID}  ${type}  OK  ${CURRENT_DATE_TIME}


Step${index}: Delete Diagnostic Request
    Log  \nStep${index}: Start Diagnostic Check through NMS.  console=true
    Run M2M Command  DELETE  "https://${VDU_OAM_IP}/api/licensed/v1/diagnostic-checks/operations/launches/${DIAGNOSTIC_OP_ID}"  Bearer  ${TOKEN}
    ...  -d "{\\"allowServiceImpact\\":true}"
    Log  Diagnostic DELETE request sent! [OK]  console=true
    ${diagnostic_get_output}  Run M2M Command  GET  "https://${VDU_OAM_IP}/api/licensed/v1/diagnostic-checks/operations/launches/${DIAGNOSTIC_OP_ID}"
    ...  Bearer  ${TOKEN}
    Should Contain  ${diagnostic_get_output}  "summary":"Not Found"
    Log  Diagnostic GET request sent, "summary":"Not Found"! [OK]  console=true


Step4: Delete CurrentPlanForRestart.Bak File From VDU
    Log  \nStep4: Delete currentPlanForRestart.bak file from vDU.  console=true
    Open SSH Connection To VDU And Connect To Openshift
    ${pod}  Get Full Name For Pod  ${VDU_CRAN}  oamcm
    ${container}  Get Full Name For Container  ${VDU_CRAN}  oamcm
    ${delete_command}  Catenate  oc exec -it -n cran1 ${pod} -c ${container} -- rm -rf
    ...                          /mnt/services/SS_OAM/OAMCM/working_dir/currentPlan/currentPlanForRestart.bak
    SSHLibrary.Write  ${delete_command}
    SSHLibrary.Read Until Prompt

    [Teardown]  SSHLibrary.Close Connection


Step6: Verify Diagnostic Check Alarm To Appear
    Log  \nStep6: Verify Diagnostic Check alarm to appear.  console=true
    Check If Fault Is Visible In VDU WebEM  7115  BASE STATION INFORMATION  4681  Diagnostic Check Error  regex:Minor|minor


Step8: Reset VDU And Check If Alarm Is Cleared
    Log  \nStep8: Reset vDU and check if alarm is cleared.  console=true
    vdu.Reset Vdu  timeout=120
    Log  Reset vDU is performed![OK]  console=true
    Wait Until Keyword Succeeds  300s  10s
    ...  Check All Cells From VDU  availability_status=${OFFLINE}  operational_state=${DISABLED}
    Log  Cells are Offline and Disabled![OK]  console=true
    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT}  10s
    ...  Check All Cells From VDU  availability_status=${ONLINE}  operational_state=${ENABLED}
    Log  Cells are Online and Enabled![OK]  console=true
    Check If Fault Is Cleared From VDU WebEM  7115  4681


TC Setup
    Common VDU Setup
    Modify Resource Search Order  WebEM__vDU__Run_Configuration_Validation_from_WebEM_Cloud_M2M_Interface
    Login Using M2M Interface  ${VDU_OAM_IP}


TC Teardown
    Logout Using M2M Interface  ${VDU_OAM_IP}
    Common VDU Teardown
