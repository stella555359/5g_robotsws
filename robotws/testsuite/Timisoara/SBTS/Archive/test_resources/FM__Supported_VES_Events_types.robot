*** Settings ***
Resource    ../../common_resources/ca_FM_general.robot

*** Variables ***
${STARTUP_TIMEOUT}          900
${RECOVERY_TIMEOUT}         900
${PING_TIMEOUT}             180
${WORKER_IP}                10.110.73.134                                       #any WORKER IP can be chosen (from ONAP)
${CA_SERVER_IP}             10.42.54.13
${CA_SERVER_PATH}           pkix
${CA_DEFAULT_PORT}          8080
${CERTS_SUBJECT_NAME}       C=PL, O=Common, CN=IPSEC
${ONAP_IP}                  10.110.73.138                                       #IP to connect to ONAP
${ONAP_USERNAME}            ute                                                 #User name for ONAP connection
${ONAP_PASSWORD}            Ut3pa5s#84b8                                        #Password for ONAP connection
${CREATE_ALARM}             Received a VESEvent
${CHANGE_ALARM}             NotifyChangedAlarmGeneral
${FAULT_NAME}               Cell blocked
${REGEX}                    ^netconf-server-[a-z0-9_-]*
${REGEX_VES}                ^dep-dcae-ves-collector-5g-[a-z0-9_-]*

*** Keywords ***
FM__Supported_VES_Events_types
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25394
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This TC is created to check if alarms appeared on WebEM and ONAP.
    ...  First alarm is triggered and will be checked on WebEM and ONAP.
    ...  Site reset id performed.
    ...  The alarm is checked again on ONAP.
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  20.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25394 - Initial TAT creation
    ...  ******************

    Set Tags  CA-FM  OWNER-cosmina.rebenciuc@nokia.com  AUTHOR-cosmina.rebenciuc@nokia.com
    ...       MAINTAINER-cosmina.rebenciuc@nokia.com    GROUP_IN_CHARGE-TIM_4_Vrf    PHASE-CRT  SW-SBTS22  FEATURE-CB007010

    Step0: Set initial variables
    Step1: Trigger first alarm
    Step2: Perform site reset
    Step3: Check alarm in VES

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
    coam.Block all cells  rat=NR
    ${create}=  Check active alarm in VES   ${CREATE_ALARM}  ${FAULT_NAME}
    Should contain  ${create}  ManagedElement=MRBTS-${BTS_ID},
    Log  Verify if alarm is visible in WebEM.  console=true
    ${status}=  Run keyword and return status  Assert alarm active  faultName="${FAULT_NAME}"  timeout=120s
    Run keyword if  ${status}
    ...  Log  Alarm with name "${FAULT_NAME}" is visible in WebEM.  console=true
    ...  ELSE
    ...  Fail  Alarm with name "${FAULT_NAME}" is not visible in WebEM.

Step2: Perform site reset
    Log  Step2: Perform site reset  console=true
    Perform site reset

Step3: Check alarm in VES
    Log  Step3: Check alarm in VES  console=true
    Sleep   300  Waiting for alarm to appear in VES.
    ${reload}  Check alarm in VES after reset
    Should contain  ${reload}  ManagedElement=MRBTS-${BTS_ID}

Recovery action
    Perform commissioning  scf_file=${new_scf_path}
    ...                    skip_parameter_relation_errors=False
    ...                    should_activate=True
    ...                    timeout=${RECOVERY_TIMEOUT}
    Log  Scf uploaded  console=true

TC Setup
    Common Test Setup

TC Teardown
    Recovery action
    Common Test Teardown
