*** Settings ***
Resource    ../../common_resources/ca_FM_general.robot

*** Variables ***
${RECOVERY_TIMEOUT}         900
${PING_TIMEOUT}             180
${WORKER_IP}                10.110.73.134                                      #any WORKER IP can be chosen (from ONAP)
${CA_SERVER_IP}             10.42.54.13
${CA_SERVER_PATH}           pkix
${CA_DEFAULT_PORT}          8080
${CERTS_SUBJECT_NAME}       C=PL, O=Common, CN=IPSEC
${ONAP_IP}                  10.110.73.138                                       #IP to connect to ONAP
${ONAP_USERNAME}            ute                                                 #User name for ONAP connection
${ONAP_PASSWORD}            Ut3pa5s#84b8                                        #Password for ONAP connection
${CREATE_ALARM}             Received a VESEvent
${CHANGE_ALARM}             NotifyChangedAlarmGeneral
${FAULT_NAME}               EAC fault 1
${SECOND_FAULT_NAME}        Cell blocked
${REGEX}                    ^netconf-server-[a-z0-9_-]*
${REGEX_VES}                ^dep-dcae-ves-collector-5g-[a-z0-9_-]*
${DNPREFIX}                 11

*** Keywords ***
FM__Report_alarms_triggered_on_SMOD_and_CELL_to_ONAP_ASIL
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25394
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This TC checks if alarms raised on SMOD and CELLs are reported to WebEM and ONAP.
    ...  First alarm is triggered and will be checked on WebEM and ONAP.
    ...  The severity is changed to Critical and will be checked on WebEM and ONAP.
    ...  The second alarm is triggered on cells and will be checked on WebEM and ONAP.
    ...  The second alarm will be canceled and will be checked on WebEM and ONAP.
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  20.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25394 - Initial TAT creation
    ...  ******************

    Set Tags  CA-FM  OWNER-cosmina.rebenciuc@nokia.com  AUTHOR-cosmina.rebenciuc@nokia.com
    ...       MAINTAINER-cosmina.rebenciuc@nokia.com    GROUP_IN_CHARGE-TIM_4_Vrf    PHASE-CRT  SW-SBTS22  FEATURE-CB007010

    Step0: Set initial variables
    Step1: Trigger first alarm
    Step2: Change severity and verify alarm
    Step3: Cancel first alarm
    Step4: Trigger second alarm
    Step5: Cancel second alarm

Step0: Set initial variables
    Log  Step0: Set initial variables  console=true
    ${BTS_ID}  Admin Get BTS ID
    Set test variable  ${BTS_ID}
    ${object}  coam.Get Managed Objects  MPLANEONAP_R
    ${status_object}  Run Keyword And Return Status  Should Be Empty  ${object}
    ${status_parameter}  Run Keyword And Return Status  Should Be Empty  ${object}[0][parameters][sftpServerHostPublicKey]
    Run Keyword If  ${status_object} or ${status_parameter}
    ...  Run keywords  Log  Running setup for CB007010  console=true  AND  Setup for CB007010
    ...  ELSE
    ...  Delete and recreate MPLANEONAP object for CB007010  ${RECOVERY_TIMEOUT}
    Wait until keyword succeeds  ${RECOVERY_TIMEOUT}  30  Check modules and cells

Step1: Trigger first alarm
    Log  Step1: Trigger first alarm  console=true
    Perform parameter recommissioning    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1
    ...                                  parameter=vesFaultCollectorEndpointDN
    ...                                  operation=update
    ...                                  value=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1/VESENDPOINT-2
    Perform parameter recommissioning    dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1/EAC_IN-1
    ...                                  parameter=inUse
    ...                                  operation=update
    ...                                  value=true
    ${create}=  Check active alarm in VES   ${CREATE_ALARM}  ${FAULT_NAME}
    Should contain  ${create}  ManagedElement=MRBTS-${BTS_ID},
    ${status}=  Run keyword and return status  Assert alarm active  faultName="${FAULT_NAME}"  timeout=120s
    Run keyword if  ${status}
    ...  Log  Alarm with name "${FAULT_NAME}" is visible in WebEM.  console=true
    ...  ELSE
    ...  Fail  Alarm with name "${FAULT_NAME}" is not visible in WebEM.

Step2: Change severity and verify alarm
    Log  Step2: Change severity and verify alarm  console=true
    Perform parameter recommissioning  dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1/EAC_IN-1
    ...                                parameter=severity
    ...                                operation=update
    ...                                value=Critical
    Log  Parameter severity was changed.  console=true
    ${change}=  Check active alarm in VES   ${CHANGE_ALARM}  ${FAULT_NAME}
    Should contain  ${change}  "perceivedSeverity":"CRITICAL"
    Log  Verify alarm with severity changed if is visible in VES.  console=true
    @{alarms}=  coam.Get active alarms
    Log  ${alarms}  console=true
    Log  Verify if alarm with new severity is visible in WebEM.  console=true
    Check if alarm changed on BTS  @{alarms}  alarm_name=${FAULT_NAME}  severity=Critical

Step3: Cancel first alarm
    Log  Step3: Cancel first alarm  console=true
    Perform parameter recommissioning  dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1/EAC_IN-1
    ...                                parameter=inUse
    ...                                operation=update
    ...                                value=false
    ${clear}=  Check cleared alarm in VES  EAC
    Log  ${clear}  console=true
    Should contain  ${clear}  ManagedElement=MRBTS-${BTS_ID},
    @{alarms}=  coam.Get active alarms
    Log  ${alarms}  console=true
    ${status}=  Run keyword and return status  Assert alarm inactive  faultName="${FAULT_NAME}"  timeout=120s
    Run keyword if  ${status}
    ...  Log  Alarm with name "${FAULT_NAME}" is cleared from WebEM.  console=true
    ...  ELSE
    ...  Fail  Alarm with name "${FAULT_NAME}" is not cleared from WebEM.

Step4: Trigger second alarm
    Log  Step4: Trigger second alarm  console=true
    Perform parameter recommissioning  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1
    ...                                parameter=vesFaultCollectorEndpointDN
    ...                                operation=update
    ...                                value=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1/VESENDPOINT-3
    Log  Parameter is changed.  console=true
    Block all cells  rat=NR
    Log  Block all NR cells.  console=true
    ${create}=  Check active alarm in VES   ${CREATE_ALARM}  ${SECOND_FAULT_NAME}
    Should contain  ${create}  ManagedElement=MRBTS-${BTS_ID},
    Log  Verify alarm in VES.  console=true
    Log  Verify is alarm is visible in WebEM.  console=true
    ${status}=  Run keyword and return status  Assert alarm active  faultName="${SECOND_FAULT_NAME}"  timeout=120s
    Run keyword if  ${status}
    ...  Log  Alarm with name "${SECOND_FAULT_NAME}" is visible in WebEM.  console=true
    ...  ELSE
    ...  Fail  Alarm with name "${SECOND_FAULT_NAME}" is not visible in WebEM.

Step5: Cancel second alarm
    Log  Step5: Cancel second alarm  console=true
    Unblock all cells  rat=NR
    ${clear}=  Check cleared alarm in VES  EAC
    Should contain  ${clear}  ManagedElement=MRBTS-${BTS_ID},
    ${status}=  Run keyword and return status  Assert alarm inactive  faultName="${SECOND_FAULT_NAME}"  timeout=120s
    Run keyword if  ${status}
    ...  Log  Alarm with name "${SECOND_FAULT_NAME}" is cleared from WebEM.  console=true
    ...  ELSE
    ...  Fail  Alarm with name "${SECOND_FAULT_NAME}" is not cleared from WebEM.

Recovery action
    Perform commissioning  scf_file=${SCF_PATH}
    ...                    skip_parameter_relation_errors=False
    ...                    should_activate=True
    ...                    timeout=${RECOVERY_TIMEOUT}
    Log  Scf uploaded  console=true

TC Setup
    Common Test Setup

TC Teardown
    Recovery action
    Common Test Teardown
