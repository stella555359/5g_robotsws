*** Settings ***
Documentation
    ...  This TC is created to verify the additional information of fault 4592 after vCU reset and restart.
    ...  The parameter fault4592CancellationTimer is set to a random value.
    ...  Next, a vCU reset is performed and fault 4592 should be raised.
    ...  The additional information should contain 'user request'.
    ...  The parameter fault4592CancellationTimer is set to 30 and Actforceautoreset is set to true.
    ...  A vCU restart is performed by deleting 'po-cranX-oamext-0 pod'.
    ...  4592 fault should be raised again.
    ...  The additional information should contain 'recovery reset'.
    ...  The fault signature is checked in WebEM.

Resource  ../../common_resources/vcu_frame.robot
Resource  ../../common_resources/vcu_general.robot


*** Keywords ***
TC__FM__vCU__FID4592_Fault_With_Recovery_Reset_Reason_In_Additional_Information
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27634
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  05.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27634 - Initial TAT creation
    ...  09.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29831 - Change method of retrieving pod and container name

    Set Tags  CA-FM  OWNER-ioan.marta@nokia.com  MAINTAINER-cosmina.rebenciuc@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT
    ...  SW-SBTS24  FEATURE-CB007964

    Step1: Set TC Preconditions
    Step2: Trigger VCU Reset
    Step3: Check Fault 4592 Was Active In WebEM
    Step4: Change Parameters To A Specific Value
    Step5: Trigger VCU Restart
    Step6: Check Fault 4592 Was Active In WebEM
    Step7: Check Fault Signature Of Fault 4592 In WebEM


Step1: Set TC Preconditions
    Log  \nStep1: Set TC preconditions  console=true

    ${date}  Get Current Date  result_format=%Y-%m-%d %H:%M:%S
    Set Test Variable  ${START_TIME}  ${date}
    ${list_values_parameter}  Create List  60  90  120  150  180
    ${value}  Evaluate  random.choice(${list_values_parameter})  random
    Change Specific Parameter For VCU  fault4592CancellationTimer  ${value}  MRBTS-${VCU_MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1
    Set Test Variable  ${EXPECTED_FAULT_NAME}  BTS Reset Cause
    Set Test Variable  ${SEVERITY_FIRST}  minor
    Set Test Variable  ${SEVERITY_SECOND}  warning
    Set Test Variable  ${ADDITIONAL_INFO_FIRST}  user request
    Set Test Variable  ${ADDITIONAL_INFO_SECOND}  recovery reset
    Set Test Variable  ${CATEGORY}  PLATFORM_RESET
    Set Test Variable  ${SCOPE}  vCU
    Set Test Variable  ${MINOR}  Container
    Set Test Variable  ${EXTRA_INFO}  affected_cells=.*NR:unknown;


Step2: Trigger VCU Reset
    Log  \nStep2: Trigger vCU reset  console=true

    Reset VCU And Wait For Ping
    Sleep  300s  Waiting for the alarm to appear in Historical Alarms.


Step${index}: Check Fault 4592 Was Active In WebEM
    Log  \nStep${index}: Check fault 4592 was active in WebEM  console=true

    IF  ${index}==3
        Checking The Presence And Additional Information Of Fault 4592 In WebEM  ${ADDITIONAL_INFO_FIRST}  ${SEVERITY_FIRST}
    ELSE
        Checking The Presence And Additional Information Of Fault 4592 In WebEM  ${ADDITIONAL_INFO_SECOND}  ${SEVERITY_SECOND}
    END


Step4: Change Parameters To A Specific Value
    Log  \nStep4: Change parameters to a specific value  console=true

    Change Specific Parameter For VCU  fault4592CancellationTimer  30  MRBTS-${VCU_MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1
    Change Specific Parameter For VCU  actForceAutoReset  true  MRBTS-${VCU_MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1


Step5: Trigger VCU Restart
    Log  \nStep5: Trigger vCU restart  console=true

    Open SSH Connection To VCU And Connect To Openshift
    ${pod}  Get Full Name For Pod  ${VDU_CRAN}  oamext
    SSHLibrary.Write  oc delete pod ${pod} -n ${VCU_CRAN}
    SSHLibrary.Read Until Prompt
    Log  vCU restart is completed.  console=true
    Sleep  120s  Waiting for the alarm to appear in Historical Alarms.
    Set Test Variable  ${INFO}  /pods/${pod} Pod with CNF-critical container is terminating


Step7: Check Fault Signature Of Fault 4592 In WebEM
    Log  \nStep7: Check fault signature of fault 4592 in WebEM  console=true

    Check Fault Signature Of Alarm In VCU In WebEM  ${EXPECTED_FAULT_NAME}
    ...                                             ${CATEGORY}
    ...                                             ${VCU_ACTIVE_SW_VERSION}
    ...                                             ${SCOPE}
    ...                                             ${MINOR}
    ...                                             ${EXTRA_INFO}
    ...                                             ${INFO}


Checking The Presence And Additional Information Of Fault 4592 In WebEM
    [Arguments]  ${additional_info}  ${severity}

    ${historical_alarms}  vcu.Get Historical Alarms  sorted_by=appearTime  sort_order=desc  timeout=120s
    ${alarms}  Get From Dictionary  ${historical_alarms}  alarms
    FOR  ${alarm}  IN  @{alarms}
        ${alarm_date}  Replace String  ${alarm}[appear_time]  T  ${SPACE}
        ${timestamp}  Fetch From Left  ${alarm_date}  +
        ${status_fault_name}  Run Keyword And Return Status  Should Contain  ${alarm}[fault_name]  ${EXPECTED_FAULT_NAME}
        ${status_severity}  Run Keyword And Return Status  Should Contain  ${alarm}[severity]  ${severity}
        IF  '${timestamp}' > '${START_TIME}' and ${status_fault_name} and ${status_severity}
            ${alarm_info}  Set Variable  ${alarm}
            BREAK
        ELSE
            CONTINUE
        END
    END
    ${status_fault_name}  Run Keyword And Return Status  Should Contain  ${alarm_info}[fault_name]  ${EXPECTED_FAULT_NAME}
    ${status_severity}  Run Keyword And Return Status  Should Contain  ${alarm_info}[severity]  ${severity}
    IF  ${status_fault_name} and ${status_severity}
        Log  Fault "${EXPECTED_FAULT_NAME}" was found in Historical Alarms.  console=true
    ELSE
        Fail  Fault "${EXPECTED_FAULT_NAME}" was not found in Historical Alarms. [NOK]
    END
    ${status}  Run Keyword And Return Status  Should Contain  ${alarm_info}[additional_info]  ${additional_info}
    IF  ${status}  Log  Additional information for alarm with fault name "${EXPECTED_FAULT_NAME}" contains "${additional_info}".  console=true


TC Setup
    Common VCU Setup
    Modify Resource Search Order  FM__vCU__FID4592_Fault_With_Recovery_Reset_Reason_In_Additional_Information


TC Teardown
    Close All Connections
    Common VCU Teardown
