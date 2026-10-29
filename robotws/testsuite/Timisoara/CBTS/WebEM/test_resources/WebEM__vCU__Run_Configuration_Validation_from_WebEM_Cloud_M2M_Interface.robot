*** Settings ***
Documentation
    ...  This TC is created to verify Diagnostic check through M2M interface.
    ...  Diagnostic check is requested and files are checked.
    ...  currentPlanForRestart is deleted and Diagnostic check is requested again.
    ...  fault 4681 is verified to be present in WebEM.
    ...  vCU reset is performed and fault must be cleared.

Library  ../../common_resources/python_resources/csv_resource.py
Resource  ../../common_resources/M2M_Interface.robot
Resource  ../../common_resources/vcu_frame.robot


*** Variables ***
${RESTORE_TIMEOUT}  15m  # Timeout for vCU to recover after SCF upload


*** Keywords ***
TC__WebEM__vCU__Run_Configuration_Validation_from_WebEM_Cloud_M2M_Interface
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27191
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  25.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27191 - Initial TAT creation
    ...  09.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29831 - Change method of retrieving pod and container name
    ...  ******************

    Set Tags  CA-WebEM  OWNER-marius.stanescu@nokia.com  MAINTAINER-anna.benzar@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  FEATURE-CB009129


    Step1: Request Full Diagnostic Check Through M2M Interface
    Step2: Open Ssh Connection To VCU And Check Diagnostic Files - WebEM Remote Tool
    Step3: Delete Diagnostic Request Through M2M Interface
    Step4: Delete currentPlanForRestart.Bak File From VCU
    Step5: Request Full Diagnostic Check Through M2M Interface
    Step6: Verify Diagnostic Check Alarm To Appear
    Step7: Delete Diagnostic Request Through M2M Interface
    Step8: Reset VCU And Check If Alarm Is Cleared


Step${index}: Request Full Diagnostic Check Through M2M Interface
    Log  \nStep${index}: Request full Diagnostic Check through M2M interface.  console=true
    ${current_date_time}  Get Current Time For Diagnostic Check
    Set Test Variable  ${CURRENT_DATE_TIME}
    ${diagnostic_post_output}  Run M2M Command  POST  "https://${VCU_OAM_IP}/api/licensed/v1/diagnostic-checks/operations/launches"  Bearer  ${TOKEN}
    ...  -d "{\\"allowServiceImpact\\":true}"
    Should Contain  ${diagnostic_post_output}  "status":"ongoing"
    Log  Diagnostic POST request sent, "status":"ongoing"! [OK]  console=true
    ${diagnostic_op_id}  Get Operation Id Value - Longer Version  ${diagnostic_post_output}
    Set Test Variable  ${DIAGNOSTIC_OP_ID}
    Sleep  10s  Wait for Diagnostic check to be done.
    ${diagnostic_get_output}  Run M2M Command  GET  "https://${VCU_OAM_IP}/api/licensed/v1/diagnostic-checks/operations/launches/${DIAGNOSTIC_OP_ID}"
    ...  Bearer  ${TOKEN}
    Should Contain  ${diagnostic_get_output}  "status":"succeeded"
    Log  Diagnostic GET request sent, "status":"succeeded"! [OK]  console=true


Step${index}: Open Ssh Connection To VCU And Check Diagnostic Files - ${type}
    Log  \nStep${index}: Open ssh connection to vCU and check Diagnostic files.  console=true
    Open Connection To VCU And Bring Diagnostic Files To Local Machine  ${VCU_CRAN}  oamcm  ${index}
    ${csv_content}  Return Csv File Content  ${TEST_RESULTS_DIR}/Diagnostic_Check_step_${index}/DiagnosticReport.csv
    Verify first row in DiagnosticReport.Csv File  ${csv_content}
    Verify second row in DiagnosticReport.Csv File  ${csv_content}  ${VCU_MRBTS_ID}  ${type}  OK  ${CURRENT_DATE_TIME}
    Verify third row in DiagnosticReport.Csv File  ${csv_content}  ${VCU_MRBTS_ID}  ${type}  OK  ${CURRENT_DATE_TIME}


Step${index}: Delete Diagnostic Request Through M2M Interface
    Log  \nStep${index}: Delete Diagnostic request through M2M interface.  console=true
    Run M2M Command  DELETE  "https://${VCU_OAM_IP}/api/licensed/v1/diagnostic-checks/operations/launches/${DIAGNOSTIC_OP_ID}"  Bearer  ${TOKEN}
    ...  -d "{\\"allowServiceImpact\\":true}"
    Log  Diagnostic DELETE request sent! [OK]  console=true
    ${diagnostic_get_output}  Run M2M Command  GET  "https://${VCU_OAM_IP}/api/licensed/v1/diagnostic-checks/operations/launches/${DIAGNOSTIC_OP_ID}"
    ...  Bearer  ${TOKEN}
    Should Contain  ${diagnostic_get_output}  "summary":"Not Found"
    Log  Diagnostic GET request sent, "summary":"Not Found"! [OK]  console=true


Step4: Delete CurrentPlanForRestart.Bak File From VCU
    Log  \nStep4: Delete currentPlanForRestart.bak file from vCU.  console=true
    Open SSH Connection To VCU And Connect To Openshift
    ${pod}  Get Full Name For Pod  ${VCU_CRAN}  oamcm
    ${container}  Get Full Name For Container  ${VCU_CRAN}  oamcm
    ${delete_command}  Catenate  oc exec -it -n ${VCU_CRAN} ${pod} -c ${container} -- rm -rf
    ...                          /mnt/services/SS_OAM/OAMCM/working_dir/currentPlan/currentPlanForRestart.bak
    SSHLibrary.Write  ${delete_command}
    SSHLibrary.Read Until Prompt

    [Teardown]  SSHLibrary.Close Connection


Step6: Verify Diagnostic Check Alarm To Appear
    Log  \nStep6: Verify Diagnostic Check alarm to appear.  console=true
    Check If Fault Is Visible In VCU WebEM  7115  BASE STATION INFORMATION  4681  Diagnostic Check Error  regex:Minor|minor


Step8: Reset VCU And Check If Alarm Is Cleared
    Log  \nStep8: Reset vCU and check if alarm is cleared.  console=true
    vcu.Reset Cu
    ${ip_adresses}  Create List  ${VCU_OAM_IP}
    ${ping_lost_status}  Run Keyword And Return Status
    ...  ping.Wait For No Ping  ip_addresses=${ip_adresses}  timeout=120s
    Run Keyword If  ${ping_lost_status} == ${FALSE}
    ...  Fail  Ping not lost after vCU reset. [NOK]
    ${ping_regained_status}  Run Keyword And Return Status
    ...  ping.Wait For Ping  ip_addresses=${ip_adresses}  timeout=300s
    Run Keyword If  ${ping_regained_status} == ${FALSE}
    ...  Fail  Ping not regained after vCU reset. [NOK]
    Log  vCU reset is performed![OK]  console=true
    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT}  10s
    ...  Check VDU To Be OnAir
    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT}  10s
    ...  Verify CU X2 Links States  ${AVAILABLE}  ${UNLOCKED}
    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT}  10s
    ...  Check Cells On VDU To Be OnAir
    Log  vDU, cells and X2 Links are back on air! [OK]  console=true
    Check If Fault Is Cleared From VCU WebEM  7115  4681


TC Setup
    Common VCU Setup
    Modify Resource Search Order  WebEM__vCU__Run_Configuration_Validation_from_WebEM_Cloud_M2M_Interface
    Login Using M2M Interface  ${VCU_OAM_IP}


TC Teardown
    Logout Using M2M Interface  ${VCU_OAM_IP}
    Common VCU Teardown
