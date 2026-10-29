*** Settings ***
Documentation
    ...  This TC is created to verify Diagnostic Check in two ways.
    ...  First, Diagnostic files are checked in OK state.
    ...  SSH connection to vDU is opened.
    ...  Diagnostic collection is started through Netact.
    ...  Check the action in Operation history.
    ...  Diagnostic files are checked.
    ...  Second way, currentPlanForRestart file is deleted.
    ...  Diagnostic collection is started.
    ...  Check the action in Operation history.
    ...  Collection results should be NOK.
    ...  Fault 4681 should be present in WebEM.
    ...  vDU reset is performed and fault should be cleared.

Library  ../../common_resources/python_resources/csv_resource.py
Resource  ../../common_resources/vdu_frame.robot


*** Variables ***
${NETACT_IP}  ${EMPTY}  # SSH ip for Netact Lab
${RECOVERY_TIMEOUT_AFTER_VDU_RESET}  1200  # Timeout for vCU to recover after reset


*** Keywords ***
TC__WebEM__vDU__Run_Configuration_Validation_from_NMS_via_ACTION_interface
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  25.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT- - Initial TAT creation
    ...  02.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28943 - Add check in Op History,change the command,change how the file is verified
    ...  09.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29831 - Change method of retrieving pod and container name
    ...  ******************

    Set Tags  CA-WebEM  OWNER-marius.stanescu@nokia.com  MAINTAINER-anna.benzar@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  FEATURE-CB009129


    Step0: TC Preconditions
    Step1: Start Diagnostic Check Through NMS
    Step2: Open Ssh Connection To VDU And Check Diagnostic Files OK
    Step3: Delete currentPlanForRestart.Bak File From VDU
    Step4: Start Diagnostic Check Through NMS
    Step5: Open Ssh Connection To VDU And Check Diagnostic Files NOK
    Step6: Verify Diagnostic Check Alarm To Appear
    Step7: Reset VDU And Check If Alarm Is Cleared


Step0: TC Preconditions
    Log  \nStep0: TC Preconditions.  console=true
    ${oamcm_pod_name}  Get Full Name For Pod  ${VDU_CRAN}  oamcm
    ${oamcm_container_name}  Get Full Name For Container  ${VDU_CRAN}  oamcm
    Set Test Variable  ${MRBTS_DN}  PLMN-PLMN/MRBTS-${VDU_MRBTS_ID}
    Set Test Variable  ${OAMCM_POD_NAME}
    Set Test Variable  ${OAMCM_CONTAINER_NAME}


Step${index}: Start Diagnostic Check Through NMS
    Log  \nStep${index}: Start Diagnostic Check through NMS.  console=true
    Open SSH Connection To Netact  ${NETACT_IP}
    SSHLibrary.Write  racclimx.sh -op Diagnostic_Check -DN ${MRBTS_DN} -neType cloudRAN -v
    SSHLibrary.Set Client Configuration  timeout=60s
    ${output}  SSHLibrary.Read Until Prompt
    ${matches}  Get Regexp Matches  ${output}  STATUS${SPACE}*:${SPACE}*SUCCESS
    ${date}  Get Current Date  result_format=%Y-%m-%d
    ${time}  Get Current Date  time_zone=UTC  result_format=%H  exclude_millis=True
    ${date_time}  Set Variable  ${date}T${time}
    Should Not Be Empty  ${matches}  Didn't manage to send Diagnostic Check command through NMS. [NOK]
    Sleep  30s  Time for the action to be visible in op history!
    ${op_history}  vdu.Get vDU Operation History
    FOR  ${dict}  IN  @{op_history}
        Dictionary Should Contain Item  ${dict}  name  NE3S_PROVISION_CM
        Should Match Regexp  ${dict}[start_time]  ${date_time}:*
        Log  NE3S_PROVISION_CM is visible in Operation History!  console=true
        Log  ${date_time} is visible in Operation History!  console=true
        Dictionary Should Contain Item  ${dict}  triggering_source  NMS
        Log  NMS is visible in Operation History!  console=true
        Should Contain  ${dict}[targets]  DIAGNOSTIC_CHECK
        Log  DIAGNOSTIC_CHECK is visible in Operation History!  console=true
        Dictionary Should Contain Item  ${dict}  status  succeeded
        Log  succeeded is visible in Operation History!  console=true
        BREAK
    END

    [Teardown]  SSHLibrary.Close Connection


Step${index}: Open Ssh Connection To VDU And Check Diagnostic Files ${status}
    Log  \nStep${index}: Open ssh connection to vDU and check Diagnostic files.  console=true
    Open SSH Connection To VDU And Connect To Openshift
    ${copy_command}  Catenate  kubectl cp ${OAMCM_POD_NAME}:mnt/services/SS_OAM/ASM/working_dir/diagnostic_check/
    ...                        -n cran1 -c ${OAMCM_CONTAINER_NAME} /var/home/core/diagnostic_check
    SSHLibrary.Write  ${copy_command}
    SSHLibrary.Read Until Prompt
    SSHLibrary.Get Directory  /var/home/core/diagnostic_check  ${TEST_RESULTS_DIR}/Diagnostic_Check_${status}
    SSHLibrary.Write  rm -rf /var/home/core/diagnostic_check
    SSHLibrary.Read Until Prompt
    ${files}  OperatingSystem.List Files In Directory  ${TEST_RESULTS_DIR}/Diagnostic_Check_${status}
    Should Contain  ${files}  DiagnosticHistoryHistogram.csv  DiagnosticHistoryHistogram.csv not found in directory. [NOK]
    Should Contain  ${files}  DiagnosticReport.csv  DiagnosticReport.csv not found in directory. [NOK]
    ${csv_content}  Return Csv File Content  ${TEST_RESULTS_DIR}/Diagnostic_Check_${status}/DiagnosticReport.csv
    Verify Specific List From CSV Content  ${csv_content}  Active configuration file presence on running SW  Check point failure  38  ${index}
    Verify Specific List From CSV Content  ${csv_content}  Configuration data valid check  Check point not executed  39  ${index}

    [Teardown]  SSHLibrary.Close Connection


Step3: Delete CurrentPlanForRestart.Bak File From VDU
    Log  \nStep3: Delete currentPlanForRestart.bak file from vDU.  console=true
    Open SSH Connection To VDU And Connect To Openshift
    ${delete_command}  Catenate  oc exec -it -n cran1 ${OAMCM_POD_NAME} -c ${OAMCM_CONTAINER_NAME} -- rm -rf
    ...                          /mnt/services/SS_OAM/OAMCM/working_dir/currentPlan/currentPlanForRestart.bak
    SSHLibrary.Write  ${delete_command}
    SSHLibrary.Read Until Prompt

    [Teardown]  SSHLibrary.Close Connection


Step6: Verify Diagnostic Check Alarm To Appear
    Log  \nStep6: Verify Diagnostic Check alarm to appear.  console=true
    Check If Fault Is Visible In VDU WebEM  7115  BASE STATION INFORMATION  4681  Diagnostic Check Error  regex:Minor|minor


Step7: Reset VDU And Check If Alarm Is Cleared
    Log  \nStep7: Reset vDU and check if alarm is cleared.  console=true
    vdu.Reset Vdu  timeout=120
    Log  Reset vDU is performed![OK]  console=true
    Wait Until Keyword Succeeds  300s  10s
    ...  Check All Cells From VDU  availability_status=${OFFLINE}  operational_state=${DISABLED}
    Log  Cells are Offline and Disabled![OK]  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT_AFTER_VDU_RESET}  10s
    ...  Check All Cells From VDU  availability_status=${ONLINE}  operational_state=${ENABLED}
    Log  Cells are Online and Enabled![OK]  console=true
    Check If Fault Is Cleared From VDU WebEM  7115  4681


Verify Specific List From CSV Content
    [Arguments]  ${csv_content}  ${check_point_name}  ${check_point_status_failed}  ${check_point_number}  ${index}

    FOR  ${list}  IN  @{csv_content}
        ${status}  Run Keyword And Return Status  List Should Contain Value  ${list}  ${check_point_name}
        IF  ${status} and ${index} == 2
            Log  ${check_point_name} is visible in DiagnosticReport.csv![OK]  console=true
            List Should Contain Value  ${list}  Check point successful
            Log  Check point successful is visible in DiagnosticReport.csv![OK]  console=true
            List Should Contain Value  ${list}  ${check_point_number}
            Log  ${check_point_number} is visible in DiagnosticReport.csv![OK]  console=true
            List Should Contain Value  ${list}  MRBTS-${VDU_MRBTS_ID}
            Log  MRBTS-${VDU_MRBTS_ID} is visible in DiagnosticReport.csv![OK]  console=true
            List Should Contain Value  ${list}  NMS
            Log  NMS is visible in DiagnosticReport.csv![OK]  console=true
            BREAK
        ELSE IF  ${status} and ${index} == 5
            Log  ${check_point_name} is visible in DiagnosticReport.csv![OK]  console=true
            List Should Contain Value  ${list}  ${check_point_status_failed}
            Log  ${check_point_status_failed} is visible in DiagnosticReport.csv![OK]  console=true
            List Should Contain Value  ${list}  ${check_point_number}
            Log  ${check_point_number} is visible in DiagnosticReport.csv![OK]  console=true
            List Should Contain Value  ${list}  MRBTS-${VDU_MRBTS_ID}
            Log  MRBTS-${VDU_MRBTS_ID} is visible in DiagnosticReport.csv![OK]  console=true
            List Should Contain Value  ${list}  NMS
            Log  NMS is visible in DiagnosticReport.csv![OK]  console=true
            BREAK
        END
    END


TC Setup
    Common VDU Setup
    Modify Resource Search Order  WebEM__vDU__Run_Configuration_Validation_from_NMS_via_ACTION_interface


TC Teardown
    Common VDU Teardown
