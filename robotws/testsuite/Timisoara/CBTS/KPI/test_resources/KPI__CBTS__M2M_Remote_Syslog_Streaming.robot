*** Settings ***
Documentation
    ...  vCU/vDU M2M Rest Api interface shall support command to configure and start syslog streaming.

Resource  ../../common_resources/M2M_Interface.robot
Resource  ../../common_resources/vcu_frame.robot
Resource  ../../common_resources/vdu_frame.robot


*** Variables ***
${SYSLOG_SERVER_HOST}  10.5.26.85
# Syslog server IP to be used. In current configuration the server runs on DCAP server.
# Server must be configured to save logs to /var/log/remote_logs with log name: BTS_Syslog_${OAM_IP}.log
# For rsyslog configuration ${OAM_IP} is the hostname.
${SYSLOG_SERVER_USER}  dcapuser
${SYSLOG_SERVER_PASSWORD}  dcapadmin!


*** Keywords ***
TC__KPI__CBTS__M2M_Remote_Syslog_Streaming
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27505
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  16.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-27505 - Initial TAT creation
    ...  ******************

    Set Tags  CA-KPI  cristian.bulea@nokia.com  AUTHOR-bogdan.boldurean@nokia.com  MAINTAINER-bogdan.boldurean@nokia.com  GROUP_IN_CHARGE-TIM_1_Vrf
    ...  PHASE-CRT  FEATURE-CB009006-G

    Step0: Set Syslog Streaming Parameters
    Step1: Check Syslog Streaming For VDU
    Step2: Check Syslog Streaming For VCU
    Step3: Start And Stop Syslog Streaming For VDU
    Step4: Start And Stop Syslog Streaming For VCU


Step0: Set Syslog Streaming Parameters
    Log  Step0: Set Syslog Streaming Parameters  console=True
    Change Specific Parameter For VCU  actCli  true  MRBTS-${VCU_MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    Change Specific Parameter For VDU  actCli  true  MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ${rand_dscp}  Evaluate  random.randint(0,15)  random
    ${random_time}  Evaluate  random.randint(1,5)  random
    Set Test Variable  ${DSCP}  ${rand_dscp}
    Set Test Variable  ${SYSLOG_COLLECTION_TIME}  ${random_time}
    Log  Set test DSCP to be used: ${DSCP}  console=true
    ssh.Connect To  ${SYSLOG_SERVER_HOST}  ${SYSLOG_SERVER_USER}  ${SYSLOG_SERVER_PASSWORD}  alias=syslog_server
    Clear File Form Server  /var/log/remote_logs/BTS_Syslog_${VDU_OAM_IP}.log  syslog_server
    Clear File Form Server  /var/log/remote_logs/BTS_Syslog_${VCU_OAM_IP}.log  syslog_server
    ${syslog_streaming_parameters}  Catenate  SEPARATOR=,  \\"server\\":\\"${SYSLOG_SERVER_HOST}\\"  \\"port\\":514  \\"protocol\\":\\"UDP\\"
    ...  \\"format\\":\\"RFC5424\\"  \\"dscp\\":${DSCP}  \\"duration\\":${SYSLOG_COLLECTION_TIME}
    Set Test Variable  ${SYSLOG_STREAMING_PARAMETERS}  ${syslog_streaming_parameters}
    OperatingSystem.Create Directory  ${TEST_RESULTS_DIR}/Syslogs


Step1: Check Syslog Streaming For VDU
    Log  Step1: Check Syslog Streaming for vDU  console=true
    Login Using M2M Interface  ${VDU_OAM_IP}
    Run M2M Command  PUT  https://${VDU_OAM_IP}/api/licensed/v1/syslog-streaming  Bearer  ${TOKEN}  -d "{${SYSLOG_STREAMING_PARAMETERS}}"
    Run M2M Command  PATCH  https://${VDU_OAM_IP}/api/licensed/v1/syslog-streaming/operation  Bearer  ${TOKEN}  -d "{\\"start\\":true}"
    Sleep  10  This is for syslog to start.
    Check Syslog Collection Is Ongoing  ${VDU_OAM_IP}
    Wait Syslog Collection To Be Finnished  ${VDU_OAM_IP}  ${SYSLOG_COLLECTION_TIME}m
    ssh.Download File  /var/log/remote_logs/BTS_Syslog_${VDU_OAM_IP}.log  ${TEST_RESULTS_DIR}/Syslogs/vDU_BTS_Syslog_${VDU_OAM_IP}.log
    ...  connection=syslog_server

    [Teardown]  Run Keywords
    ...  Logout Using M2M Interface  ${VDU_OAM_IP}
    ...  AND
    ...  Clear File Form Server  /var/log/remote_logs/BTS_Syslog_${VDU_OAM_IP}.log  syslog_server


Step2: Check Syslog Streaming For VCU
    Log  Step2: Check Syslog Streaming for vCU  console=true
    Login Using M2M Interface  ${VCU_OAM_IP}
    Run M2M Command  PUT  https://${VCU_OAM_IP}/api/licensed/v1/syslog-streaming  Bearer  ${TOKEN}  -d "{${SYSLOG_STREAMING_PARAMETERS}}"
    Run M2M Command  PATCH  https://${VCU_OAM_IP}/api/licensed/v1/syslog-streaming/operation  Bearer  ${TOKEN}  -d "{\\"start\\":true}"
    Sleep  10  This is for syslog to start.
    Check Syslog Collection Is Ongoing  ${VCU_OAM_IP}
    Wait Syslog Collection To Be Finnished  ${VCU_OAM_IP}  ${SYSLOG_COLLECTION_TIME}m
    ssh.Download File  /var/log/remote_logs/BTS_Syslog_${VCU_OAM_IP}.log  ${TEST_RESULTS_DIR}/Syslogs/vCU_BTS_Syslog_${VCU_OAM_IP}.log
    ...  connection=syslog_server

    [Teardown]  Run Keywords
    ...  Logout Using M2M Interface  ${VCU_OAM_IP}
    ...  AND
    ...  Clear File Form Server  /var/log/remote_logs/BTS_Syslog_${VCU_OAM_IP}.log  syslog_server


Step3: Start And Stop Syslog Streaming For VDU
    Log  Step3: Start and Stop Syslog Streaming for vDU  console=true
    Login Using M2M Interface  ${VDU_OAM_IP}
    Run M2M Command  PUT  https://${VDU_OAM_IP}/api/licensed/v1/syslog-streaming  Bearer  ${TOKEN}  -d "{${SYSLOG_STREAMING_PARAMETERS}}"
    Run M2M Command  PATCH  https://${VDU_OAM_IP}/api/licensed/v1/syslog-streaming/operation  Bearer  ${TOKEN}  -d "{\\"start\\":true}"
    Sleep  10  This is for syslog to start.
    Check Syslog Collection Is Ongoing  ${VDU_OAM_IP}
    Run M2M Command  PATCH  https://${VDU_OAM_IP}/api/licensed/v1/syslog-streaming/operation  Bearer  ${TOKEN}  -d "{\\"start\\":false}"
    Sleep  5  Wait for syslog to stop.
    ${syslog_status}  Get Syslog Collection Status  ${VDU_OAM_IP}
    Run Keyword If  '${syslog_status}'=='on'
    ...  Fail  Syslog not stoped for vDU.
    ssh.Download File  /var/log/remote_logs/BTS_Syslog_${VDU_OAM_IP}.log  ${TEST_RESULTS_DIR}/Syslogs/vDU_stop_BTS_Syslog_${VDU_OAM_IP}.log
    ...  connection=syslog_server

    [Teardown]  Run Keywords
    ...  Logout Using M2M Interface  ${VDU_OAM_IP}
    ...  AND
    ...  Clear File Form Server  /var/log/remote_logs/BTS_Syslog_${VDU_OAM_IP}.log  syslog_server


Step4: Start And Stop Syslog Streaming For VCU
    Log  Step4: Start and Stop Syslog Streaming for vCU  console=true
    Login Using M2M Interface  ${VCU_OAM_IP}
    Run M2M Command  PUT  https://${VCU_OAM_IP}/api/licensed/v1/syslog-streaming  Bearer  ${TOKEN}  -d "{${SYSLOG_STREAMING_PARAMETERS}}"
    Run M2M Command  PATCH  https://${VCU_OAM_IP}/api/licensed/v1/syslog-streaming/operation  Bearer  ${TOKEN}  -d "{\\"start\\":true}"
    Sleep  10  This is for syslog to start.
    Check Syslog Collection Is Ongoing  ${VCU_OAM_IP}
    Run M2M Command  PATCH  https://${VCU_OAM_IP}/api/licensed/v1/syslog-streaming/operation  Bearer  ${TOKEN}  -d "{\\"start\\":false}"
    Sleep  5  Wait for syslog to stop.
    ${syslog_status}  Get Syslog Collection Status  ${VCU_OAM_IP}
    Run Keyword If  '${syslog_status}'=='on'
    ...  Fail  Syslog not stoped for vCU.
    ssh.Download File  /var/log/remote_logs/BTS_Syslog_${VCU_OAM_IP}.log  ${TEST_RESULTS_DIR}/Syslogs/vCU_stop_BTS_Syslog_${VCU_OAM_IP}.log
    ...  connection=syslog_server

    [Teardown]  Run Keywords
    ...  Logout Using M2M Interface  ${VCU_OAM_IP}
    ...  AND
    ...  Clear File Form Server  /var/log/remote_logs/BTS_Syslog_${VCU_OAM_IP}.log  syslog_server


TC Setup
    Common VCU Setup
    Common VDU Setup
    Modify Resource Search Order  KPI__CBTS__M2M_Remote_Syslog_Streaming


TC Teardown
    Common VCU Teardown
    Common VDU Teardown
