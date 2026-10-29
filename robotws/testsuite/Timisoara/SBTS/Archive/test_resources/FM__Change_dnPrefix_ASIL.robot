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
${REGEX}                    ^netconf-server-[a-z0-9_-]*
${REGEX_VES}                ^dep-dcae-ves-collector-5g-[a-z0-9_-]*
${DNPREFIX}                 11

*** Keywords ***
FM__Change_dnPrefix_ASIL
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25394
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This TC is created to check if alarms appeared on WebEM and ONAP after 2 faults have been triggered.
    ...  First alarm is triggered and will be checked in WebEM and ONAP.
    ...  Then the alarm will be canceled.
    ...  Second alarm is triggered and will be checked in WebEM and ONAP.
    ...  The the alarm will be canceled.
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  20.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25394 - Initial TAT creation
    ...  ******************

    Set Tags  CA-FM  OWNER-cosmina.rebenciuc@nokia.com  AUTHOR-cosmina.rebenciuc@nokia.com
    ...       MAINTAINER-cosmina.rebenciuc@nokia.com    GROUP_IN_CHARGE-TIM_4_Vrf    PHASE-CRT  SW-SBTS22  FEATURE-CB007010

    Step0: Set initial variables
    Step1: Trigger first alarm
    Step2: Cancel first alarm
    Step3: Trigger alarm for the second time
    Step4: Cancel second alarm

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
    Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1/EAC_IN-1
    ...                                parameter=portId
    ...                                operation=update
    ...                                value=3
    Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1/EAC_IN-1
    ...                                parameter=inUse
    ...                                operation=update
    ...                                value=true
    ${create}  Check active alarm in VES  ${CREATE_ALARM}  ${FAULT_NAME}
    Should contain  ${create}  ManagedElement=MRBTS-${BTS_ID},
    ${status}=  Run keyword and return status  Assert alarm active  faultName="${FAULT_NAME}"
    Run keyword if  ${status}
    ...  Log  Alarm with name "${FAULT_NAME}" is visible in WebEM.  console=true
    ...  ELSE
    ...  Fail  Alarm with name "${FAULT_NAME}" is not visible in WebEM.

Step2: Cancel first alarm
    Log  Step2: Cancel first alarm  console=true
    Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1/EAC_IN-1
    ...                                parameter=inUse
    ...                                operation=update
    ...                                value=false
    ${clear}  Check cleared alarm in VES  EAC
    Log  ${clear}  console=true
    Should contain  ${clear}  ManagedElement=MRBTS-${BTS_ID},
    ${status}=  Run keyword and return status  Assert alarm inactive  faultName="${FAULT_NAME}"
    Run keyword if  ${status}
    ...  Log  Alarm with name "${FAULT_NAME}" is cleared from WebEM.  console=true
    ...  ELSE
    ...  Fail  Alarm with name "${FAULT_NAME}" is not cleared from WebEM.

Step3: Trigger alarm for the second time
    Log  Step3: Trigger alarm for the second time  console=true
    Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}
    ...                                parameter=dnPrefix
    ...                                operation=update
    ...                                value=${DNPREFIX}
    Sleep  180  Wait for changes to be applied.
    Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1/EAC_IN-1
    ...                                parameter=inUse
    ...                                operation=update
    ...                                value=true
    ${create}  Check active alarm in VES  ${CREATE_ALARM}  ${FAULT_NAME}
    Should contain  ${create}  ${DNPREFIX},ManagedElement=MRBTS-${BTS_ID},
    ${status}=  Run keyword and return status  Assert alarm active  faultName="${FAULT_NAME}"
    Run keyword if  ${status}
    ...  Log  Alarm with name "${FAULT_NAME}" is visible in WebEM.  console=true
    ...  ELSE
    ...  Fail  Alarm with name "${FAULT_NAME}" is not visible in WebEM.

Step4: Cancel second alarm
    Log  Step4: Cancel second alarm  console=true
    Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1/EAC_IN-1
    ...                                parameter=inUse
    ...                                operation=update
    ...                                value=false
    ${clear}  Check cleared alarm in VES  EAC
    Log  ${clear}  console=true
    Should contain  ${clear}  ${DNPREFIX},ManagedElement=MRBTS-${BTS_ID},
    ${status}=  Run keyword and return status  Assert alarm inactive  faultName="${FAULT_NAME}"
    Run keyword if  ${status}
    ...  Log  Alarm with name "${FAULT_NAME}" is cleared from WebEM.  console=true
    ...  ELSE
    ...  Fail  Alarm with name "${FAULT_NAME}" is not cleared from WebEM.

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
