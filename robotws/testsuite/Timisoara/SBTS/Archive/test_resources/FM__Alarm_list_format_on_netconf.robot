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
FM__Alarm_list_format_on_netconf
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25394
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This TC is created to check alarm list on Netconf.
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  20.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25394 - Initial TAT creation
    ...  ******************

    Set Tags  CA-FM  OWNER-cosmina.rebenciuc@nokia.com  AUTHOR-cosmina.rebenciuc@nokia.com
    ...       MAINTAINER-cosmina.rebenciuc@nokia.com    GROUP_IN_CHARGE-TIM_4_Vrf    PHASE-CRT  SW-SBTS22  FEATURE-CB007010

    Step0: Set initial variables
    Step1: Check alarm format in Netconf

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

Step1: Check alarm format in Netconf
    Log  Step1: Check alarm format in Netconf  console=true
    ${get_output}=   Get alarms from ONAP   ${ONAP_IP}   ${ONAP_USERNAME}   ${ONAP_PASSWORD}
    RUN   echo "${get_output}" > /home/ute/test1.txt
    ${output}=    RUN   cat /home/ute/test1.txt | grep '<ManagedElement xmlns=urn:3gpp:sa5:_3gpp-common-managed-element>'
    Should contain      ${output}       <ManagedElement
    ${output2}=   RUN    cat /home/ute/test1.txt | grep '\\s\\s<AlarmList>'
    Should contain      ${output2}      <AlarmList>
    ${output3}=   RUN    cat /home/ute/test1.txt | grep '\\s\\s\\s<alarmRecords>'
    Should contain      ${output3}      <alarmRecords>

Recovery action
    Perform commissioning  scf_file=${SCF_PATH}
    ...                    skip_parameter_relation_errors=False
    ...                    should_activate=True
    ...                    timeout=${RECOVERY_TIMEOUT}
    Wait until keyword succeeds  ${RECOVERY_TIMEOUT}  30  Check modules and cells
    Log  Scf uploaded  console=true

TC Setup
    Common Test Setup

TC Teardown
    Recovery action
    Common Test Teardown
