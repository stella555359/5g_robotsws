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
${FAULT_NAME}               Cell blocked
${REGEX}                    ^netconf-server-[a-z0-9_-]*
${REGEX_VES}                ^dep-dcae-ves-collector-5g-[a-z0-9_-]*

*** Keywords ***
FM__Enriching_alarm_content_sent_to_ONAP_ASIL
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25394
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This TC checks if raised alarm is reported to NetConf and ONAP in correct form.
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  20.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25394 - Initial TAT creation
    ...  ******************

    Set Tags  CA-FM  OWNER-cosmina.rebenciuc@nokia.com  AUTHOR-cosmina.rebenciuc@nokia.com
    ...       MAINTAINER-cosmina.rebenciuc@nokia.com    GROUP_IN_CHARGE-TIM_4_Vrf    PHASE-CRT  SW-SBTS22  FEATURE-CB007010

    Step0: Set initial variables
    Step1: Trigger first alarm

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
    ${alarm_ves}=  Check active alarm in VES  ${CREATE_ALARM}  ${FAULT_NAME}
    Should contain  ${alarm_ves}  ${FAULT_NAME}
    Log  Alarm with faultName "${FAULT_NAME}" is visible in VES.  console=true
    Should not contain  ${alarm_ves}  ai_vs_OCFDN
    ${get_output}=  Get alarms from ONAP  ${ONAP_IP}  ${ONAP_USERNAME}  ${ONAP_PASSWORD}
    RUN  echo "${alarmRecords}" > /home/ute/test.txt
    ${alarm_netconf}=  RUN  cat /home/ute/test.txt | grep -B 9 -A 2 "${FAULT_NAME}"
    Should contain  ${alarm_netconf}  <alarmRecords>
    Should not contain  ${alarm_netconf}  ai_vs_OCFDN
    Should contain  ${alarm_netconf}  ${FAULT_NAME}
    Should contain  ${alarm_netconf}  49

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

