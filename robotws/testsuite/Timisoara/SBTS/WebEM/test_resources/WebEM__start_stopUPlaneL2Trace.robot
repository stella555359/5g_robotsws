*** Settings ***
Documentation
    ...  This test case is transferred from BOAM_ET to ST_OAM_WebEM.
    ...  This test start and stop UPlaneL2Trace via ADMIN CLI.
    ...  actCli parameter is changed to be true.
    ...  Start UPlaneL2Trace command via ADMIN CLI is performed.
    ...  Verify for command to be sent with status completed, message succeeded and error code 0.
    ...  Stop UPlaneL2Trace command via ADMIN CLI is performed.
    ...  Verify for command to be sent with status completed, message succeeded and error code 0.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${IP}  10.15.236.145  # Ip for UPlaneL2 NR


*** Keywords ***
TC__WebEM__start_stopUPlaneL2Trace
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24241
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 14.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24241 - Initial TAT creation
    ...  - 15.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24316 - Refactor WebEM TCs and resources to use KWs from ca_SBTS_general

    Set Tags  CA-WebEM  OWNER-cristina.antoci@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS23

    Step1: Change ActCli Parameter To Be true
    Step2: Start UPlane L2 Trace Via ADMIN CLI
    Step3: Stop UPlane L2 Trace Via ADMIN CLI
    Step4: Change ActCli Parameter To Be false


Step${id}: Change ActCli Parameter To Be ${value}
    Log  \nStep${id}: Change actCli parameter to be ${value}  console=true
    Change ActCli Parameter  ${value}


Step2: Start UPlane L2 Trace Via ADMIN CLI
    Log  \nStep2: Start UPlane L2 Trace via ADMIN CLI  console=true
    Setup Admin CLI  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}
    ${nrcell_ids}  Get Ids For All  NRCEL
    ${length}  Get Length  ${nrcell_ids}
    ${nrcell}  Run Keyword If  ${length}>1
    ...  Evaluate  random.choice(${nrcell_ids})  random
    ...  ELSE
    ...  Set Variable  ${nrcell_ids}[0]
    ${nrcell_id}  Fetch From Right  ${nrcell}  NRCELL_R-
    ${request}  Catenate  SEPARATOR=  {"requestId":2,"parameters":{"name":"startUPlaneL2Trace","parameters":
    ...  {"nrCellDNs":["MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-${nrcell_id}"],"configurationParameters":
    ...  {"sourceIp":"${IP}","dscp":3,"destinationIp":"${IP}","destinationPort":1025},"upSw":"L2Ps","traceType":"Component"}}}
    Log  Sending command via Admin CLI for startUPlaneL2Trace...  console=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  ${request}
    Run Keyword If  '${request_status}' == 'completed' and '${request_message}' == 'Succeeded' and ${error_code} == 0
    ...  Log  Command sent with status: ${request_status}, message: ${request_message} and error code: ${error_code}  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status}, message: ${request_message} and error code: ${error_code}


Step3: Stop UPlane L2 Trace Via ADMIN CLI
    Log  \nStep3: Stop UPlane L2 Trace via ADMIN CLI  console=true
    ${request}  Catenate  SEPARATOR=  {"requestId":2,"parameters":{"name":"stopUPlaneL2Trace",
    ...  "parameters":{"upSw":"L2Ps","traceType":"Component"}}}
    Log  Sending command via Admin CLI for stopUPlaneL2Trace...  console=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  ${request}
    Run Keyword If  '${request_status}' == 'completed' and '${request_message}' == 'Succeeded' and ${error_code} == 0
    ...  Log  Command sent with status: ${request_status}, message: ${request_message} and error code: ${error_code}  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status}, message: ${request_message} and error code: ${error_code}


TC Setup
    Common Test Setup


TC Teardown
    Common Test Teardown
