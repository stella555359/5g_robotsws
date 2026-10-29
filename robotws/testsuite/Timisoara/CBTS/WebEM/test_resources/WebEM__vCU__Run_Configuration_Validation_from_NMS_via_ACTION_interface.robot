*** Settings ***
Documentation
    ...  This TC is created to verify Diagnostic Check in two ways.
    ...  First, Diagnostic files are checked in OK state.
    ...  SSH connection to vCU is opened.
    ...  Diagnostic collection is started through Netact.
    ...  Check the action in Operation history.
    ...  Diagnostic files are checked.
    ...  Second way, currentPlanForRestart file is deleted.
    ...  Diagnostic collection is started.
    ...  Check the action in Operation history.
    ...  Collection results should be NOK.
    ...  Fault 4681 should be present in WebEM.
    ...  vCU reset is performed and fault should be cleared.

Library  ../../common_resources/python_resources/csv_resource.py
Resource  ../../common_resources/vcu_frame.robot


*** Variables ***
${NETACT_IP}  ${EMPTY}  # SSH ip for Netact Lab
${RECOVERY_TIMEOUT_AFTER_VCU_RESET}  1200  # Timeout for vCU to recover after reset


*** Keywords ***
TC__WebEM__vCU__Run_Configuration_Validation_from_NMS_via_ACTION_interface
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27187
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  25.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27187 - Initial TAT creation
    ...  02.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28930 - Add check in Op History,change the command,change how the file is verified
    ...  09.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29831 - Change method of retrieving pod and container name
    ...  ******************

    Set Tags  CA-WebEM  OWNER-marius.stanescu@nokia.com  MAINTAINER-anna.benzar@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  FEATURE-CB009129


    Step0: TC Preconditions
    Step1: Start Diagnostic Check Through Netact
    Step2: Open Ssh Connection To VCU And Check Diagnostic Files OK
    Step3: Delete currentPlanForRestart.Bak File From VCU
    Step4: Start Diagnostic Check Through Netact
    Step5: Open Ssh Connection To VCU And Check Diagnostic Files NOK
    Step6: Verify Diagnostic Check Alarm To Appear On VCU
    Step7: Reset VCU And Check If Alarm Is Cleared


Step0: TC Preconditions
    Log  \nStep0: TC Preconditions.  console=true
    ${oamcm_pod_name}  Get Full Name For Pod  ${VCU_CRAN}  oamcm
    ${oamcm_container_name}  Get Full Name For Container  ${VCU_CRAN}  oamcm
    Set Test Variable  ${MRBTS_DN}  PLMN-PLMN/MRBTS-${VCU_MRBTS_ID}
    Set Test Variable  ${OAMCM_POD_NAME}
    Set Test Variable  ${OAMCM_CONTAINER_NAME}


Step${index}: Start Diagnostic Check Through Netact
    Log  \nStep${index}: Start Diagnostic Check through Netact.  console=true
    Open SSH Connection To Netact  ${NETACT_IP}
    SSHLibrary.Write  racclimx.sh -op Diagnostic_Check -DN ${MRBTS_DN} -neType cloudRAN -v
    SSHLibrary.Set Client Configuration  timeout=60s
    ${output}  SSHLibrary.Read Until Prompt
    ${matches}  Get Regexp Matches  ${output}  STATUS${SPACE}*:${SPACE}*SUCCESS
    ${date}  Get Current Date  result_format=%Y-%m-%d
    Should Not Be Empty  ${matches}  Didn't manage to send Diagnostic Check command through NMS. [NOK]
    Sleep  30s  Time for the action to be visible in op history!
    ${op_history}  vcu.Get CU Operation History
    ${op_history_list}  Get From Dictionary  ${op_history}  created
    FOR  ${dict}  IN  @{op_history_list}
        Dictionary Should Contain Item  ${dict}  name  NE3S_PROVISION_CM
        Should Match Regexp  ${dict}[start_time]  ${date}T*
        Log  NE3S_PROVISION_CM is visible in Operation History!  console=true
        Log  ${date} is visible in Operation History!  console=true
        Dictionary Should Contain Item  ${dict}  triggering_source  NMS
        Log  NMS is visible in Operation History!  console=true
        Should Contain  ${dict}[targets]  DIAGNOSTIC_CHECK
        Log  DIAGNOSTIC_CHECK is visible in Operation History!  console=true
        Dictionary Should Contain Item  ${dict}  status  succeeded
        Log  succeeded is visible in Operation History!  console=true
        BREAK
    END

    [Teardown]  SSHLibrary.Close Connection


Step${index}: Open Ssh Connection To VCU And Check Diagnostic Files ${status}
    Log  \nStep${index}: Open ssh connection to vCU and check Diagnostic files ${status}.  console=true
    Open SSH Connection To VCU And Connect To Openshift
    ${copy_command}  Catenate  kubectl cp ${OAMCM_POD_NAME}:mnt/services/SS_OAM/ASM/working_dir/diagnostic_check/
    ...                        -n ${VCU_CRAN} -c ${OAMCM_CONTAINER_NAME} /var/home/core/diagnostic_check
    SSHLibrary.Write  ${copy_command}
    SSHLibrary.Read Until Prompt
    SSHLibrary.Get Directory  /var/home/core/diagnostic_check  ${TEST_RESULTS_DIR}/Diagnostic_Check_${status}
    SSHLibrary.Write  rm -rf /var/home/core/diagnostic_check
    SSHLibrary.Read Until Prompt
    ${files}  OperatingSystem.List Files In Directory  ${TEST_RESULTS_DIR}/Diagnostic_Check_${status}
    Should Contain  ${files}  DiagnosticHistoryHistogram.csv  DiagnosticHistoryHistogram.csv not found in directory. [NOK]
    Should Contain  ${files}  DiagnosticReport.csv  DiagnosticReport.csv not found in directory. [NOK]
    ${csv_content}  Return Csv File Content  ${TEST_RESULTS_DIR}/Diagnostic_Check_${status}/DiagnosticReport.csv
    Verify Specific List From CSV Content For vCU
    ...  ${csv_content}  Active configuration file presence on running SW  Check point failure  38  ${index}
    Verify Specific List From CSV Content For vCU
    ...  ${csv_content}  Configuration data valid check  Check point not executed  39  ${index}

    [Teardown]  SSHLibrary.Close Connection


Step3: Delete CurrentPlanForRestart.Bak File From VCU
    Log  \nStep3: Delete currentPlanForRestart.bak file from vCU.  console=true
    Open SSH Connection To VCU And Connect To Openshift
    ${delete_command}  Catenate  oc exec -it -n ${VCU_CRAN} ${OAMCM_POD_NAME} -c ${OAMCM_CONTAINER_NAME} -- rm -rf
    ...                         /mnt/services/SS_OAM/OAMCM/working_dir/currentPlan/currentPlanForRestart.bak
    SSHLibrary.Write  ${delete_command}
    SSHLibrary.Read Until Prompt

    [Teardown]  SSHLibrary.Close Connection


Step6: Verify Diagnostic Check Alarm To Appear On VCU
    Log  \nStep6: Verify Diagnostic Check alarm to appear on vCU.  console=true
    Check If Fault Is Visible In VCU WebEM  7115  BASE STATION INFORMATION  4681  Diagnostic Check Error  regex:Minor|minor


Step7: Reset VCU And Check If Alarm Is Cleared
    Log  \nStep7: Reset vCU and check if alarm is cleared.  console=true
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
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT_AFTER_VCU_RESET}  10s
    ...  Check VDU To Be OnAir
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT_AFTER_VCU_RESET}  10s
    ...  Verify CU X2 Links States  ${AVAILABLE}  ${UNLOCKED}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT_AFTER_VCU_RESET}  10s
    ...  Check Cells On VDU To Be OnAir
    Log  vDU, cells and X2 Links are back on air! [OK]  console=true
    Check If Fault Is Cleared From VCU WebEM  7115  4681


Verify Specific List From CSV Content For vCU
    [Arguments]  ${csv_content}  ${check_point_name}  ${check_point_status_failed}  ${check_point_number}  ${index}

    FOR  ${list}  IN  @{csv_content}
        ${status}  Run Keyword And Return Status  List Should Contain Value  ${list}  ${check_point_name}
        IF  ${status} and ${index} == 2
            Log  ${check_point_name} is visible in DiagnosticReport.csv![OK]  console=true
            List Should Contain Value  ${list}  Check point successful
            Log  Check point successful is visible in DiagnosticReport.csv![OK]  console=true
            List Should Contain Value  ${list}  ${check_point_number}
            Log  ${check_point_number} is visible in DiagnosticReport.csv![OK]  console=true
            List Should Contain Value  ${list}  MRBTS-${VCU_MRBTS_ID}
            Log  MRBTS-${VCU_MRBTS_ID} is visible in DiagnosticReport.csv![OK]  console=true
            List Should Contain Value  ${list}  NMS
            Log  NMS is visible in DiagnosticReport.csv![OK]  console=true
            BREAK
        ELSE IF  ${status} and ${index} == 5
            Log  ${check_point_name} is visible in DiagnosticReport.csv![OK]  console=true
            List Should Contain Value  ${list}  ${check_point_status_failed}
            Log  ${check_point_status_failed} is visible in DiagnosticReport.csv![OK]  console=true
            List Should Contain Value  ${list}  ${check_point_number}
            Log  ${check_point_number} is visible in DiagnosticReport.csv![OK]  console=true
            List Should Contain Value  ${list}  MRBTS-${VCU_MRBTS_ID}
            Log  MRBTS-${VCU_MRBTS_ID} is visible in DiagnosticReport.csv![OK]  console=true
            List Should Contain Value  ${list}  NMS
            Log  NMS is visible in DiagnosticReport.csv![OK]  console=true
            BREAK
        END
    END


TC Setup
    Common VCU Setup
    Modify Resource Search Order  WebEM__vCU__Run_Configuration_Validation_from_NMS_via_ACTION_interface


TC Teardown
    Common VCU Teardown
