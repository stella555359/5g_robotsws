*** Settings ***
Documentation
    ...  vCU/vDU M2M Rest Api interface shall support command to configure and start syslog streaming.
    ...  Rest vDU and vCU while syslogs are streaming.
    ...  Change time interval for syslog collection.
    ...  Check operation history.

Resource  ../../common_resources/M2M_Interface.robot
Resource  ../../common_resources/vcu_frame.robot
Resource  ../../common_resources/vdu_frame.robot


*** Variables ***
${SYSLOG_COLLECTION_TIME}  10  # Initial time for syslog streaming
${SYSLOG_SERVER_HOST}  10.5.26.85
# Syslog server IP to be used. In current configuration the server runs on DCAP server.
# Server must be configured to save logs to /var/log/remote_logs with log name: BTS_Syslog_${OAM_IP}.log
# For rsyslog configuration ${OAM_IP} is the hostname.
${SYSLOG_SERVER_USER}  dcapuser
${SYSLOG_SERVER_PASSWORD}  dcapadmin!
${RECOVERY_TIMEOUT}  900s  # Timeout for CBTS to be onAir


*** Keywords ***
TC__KPI__CBTS__M2M_Remote_Syslog_Streaming_Reset_API
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27754
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  05.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-27754 - Initial TAT creation
    ...  28.01.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28643 - Fix syslog file permissions
    ...  10.03.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28868 - Add wait for vDU and vCU API to be available after reset.
    ...  ******************

    Set Tags  CA-KPI  OWNER-cristian.bulea@nokia.com  AUTHOR-bogdan.boldurean@nokia.com  GROUP_IN_CHARGE-TIM_1_Vrf
    ...  PHASE-CRT  FEATURE-CB009006-G

    Step0: Set Parameters
    Step1: Start Syslog Streaming For VDU
    Step2: Reset VDU
    Step3: Change Time Interval For Syslog Streaming VDU
    Step4: Check Operation History VDU
    Step5: Start Syslog Streaming For VCU
    Step6: Reset VCU
    Step7: Change Time Interval For Syslog Streaming VCU
    Step8: Check Operation History VCU
    Step9: Check Cells Are Enabled


Step0: Set Parameters
    Log  Step0: Set Parameter  console=True
    Change Specific Parameter For VCU  actCli  true  MRBTS-${VCU_MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    Change Specific Parameter For VDU  actCli  true  MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ${rand_dscp}  Evaluate  random.randint(0,15)  random
    Set Test Variable  ${DSCP}  ${rand_dscp}
    Log  Set test DSCP to be used: ${DSCP}  console=true
    ssh.Connect To  ${SYSLOG_SERVER_HOST}  ${SYSLOG_SERVER_USER}  ${SYSLOG_SERVER_PASSWORD}  alias=syslog_server
    Clear File Form Server  /var/log/remote_logs/BTS_Syslog_${VDU_OAM_IP}.log  syslog_server
    Clear File Form Server  /var/log/remote_logs/BTS_Syslog_${VCU_OAM_IP}.log  syslog_server
    ${syslog_streaming_parameters}  Catenate  SEPARATOR=,  \\"server\\":\\"${SYSLOG_SERVER_HOST}\\"  \\"port\\":514  \\"protocol\\":\\"UDP\\"
    ...  \\"format\\":\\"RFC5424\\"  \\"dscp\\":${DSCP}  \\"duration\\":5
    Set Test Variable  ${SYSLOG_STREAMING_PARAMETERS}  ${syslog_streaming_parameters}
    OperatingSystem.Create Directory  ${TEST_RESULTS_DIR}/Syslogs


Step1: Start Syslog Streaming For VDU
    Log  Step1: Start Syslog Streaming for vDU  console=true
    Login Using M2M Interface  ${VDU_OAM_IP}
    Run M2M Command  PUT  https://${VDU_OAM_IP}/api/licensed/v1/syslog-streaming  Bearer  ${TOKEN}  -d "{${SYSLOG_STREAMING_PARAMETERS}}"
    Run M2M Command  PATCH  https://${VDU_OAM_IP}/api/licensed/v1/syslog-streaming/operation  Bearer  ${TOKEN}  -d "{\\"start\\":true}"
    Sleep  10  This is for syslog to start.
    Check Syslog Collection Is Ongoing  ${VDU_OAM_IP}


Step2: Reset VDU
    Log  Step2: Reset vDU  console=true
    Reset VDU And Wait For Ping
    Log  Wait 30s for vDU API to be available.  console=true
    Sleep  30s
    Check Syslog Collection Is Ongoing  ${VDU_OAM_IP}


Step3: Change Time Interval For Syslog Streaming VDU
    Log  Step3: Change Time Interval for Syslog Streaming vDU  console=true
    ${syslog_streaming_parameters}  Catenate  SEPARATOR=,  \\"server\\":\\"${SYSLOG_SERVER_HOST}\\"  \\"port\\":514  \\"protocol\\":\\"UDP\\"
    ...  \\"format\\":\\"RFC5424\\"  \\"dscp\\":${DSCP}  \\"duration\\":2
    Run M2M Command  PUT  https://${VDU_OAM_IP}/api/licensed/v1/syslog-streaming  Bearer  ${TOKEN}  -d "{${syslog_streaming_parameters}}"
    Check Time Is Updated  ${VDU_OAM_IP}  2
    Check Syslog Collection Is Ongoing  ${VDU_OAM_IP}
    Wait Syslog Collection To Be Finnished  ${VDU_OAM_IP}  ${SYSLOG_COLLECTION_TIME}m
    ssh.Execute  sudo chmod 444 /var/log/remote_logs/BTS_Syslog_${VDU_OAM_IP}.log  connection=syslog_server
    ${ls_output}  ssh.Execute  ls -l /var/log/remote_logs  connection=syslog_server
    ${lines}  Get Lines Containing String  ${ls_output}  BTS_Syslog_${VDU_OAM_IP}.log
    Should Contain  ${lines}  r--r--r--  Coudn't grant reading permissions to BTS_Syslog_${VDU_OAM_IP}.log file.[NOK]
    ssh.Download File  /var/log/remote_logs/BTS_Syslog_${VDU_OAM_IP}.log  ${TEST_RESULTS_DIR}/Syslogs/vDU_BTS_Syslog_${VDU_OAM_IP}.log
    ...  connection=syslog_server

    [Teardown]  Run Keywords
    ...  Logout Using M2M Interface  ${VDU_OAM_IP}
    ...  AND
    ...  Clear File Form Server  /var/log/remote_logs/BTS_Syslog_${VDU_OAM_IP}.log  syslog_server


Step4: Check Operation History VDU
    Log  Step4: Check operation history vDU  console=true
    ${operation_history}  vdu.Get Vdu Operation History
    Check Operation History  ${operation_history}  Start vCU/vDU remote syslog streaming  M2M


Step5: Start Syslog Streaming For VCU
    Log  Step5: Start Syslog Streaming for vCU  console=true
    Login Using M2M Interface  ${VCU_OAM_IP}
    Run M2M Command  PUT  https://${VCU_OAM_IP}/api/licensed/v1/syslog-streaming  Bearer  ${TOKEN}  -d "{${SYSLOG_STREAMING_PARAMETERS}}"
    Run M2M Command  PATCH  https://${VCU_OAM_IP}/api/licensed/v1/syslog-streaming/operation  Bearer  ${TOKEN}  -d "{\\"start\\":true}"
    Sleep  10  This is for syslog to start.
    Check Syslog Collection Is Ongoing  ${VCU_OAM_IP}


Step6: Reset VCU
    Log  Step6: Reset vCU  console=true
    Reset VCU And Wait For Ping
    Log  Wait 30s for vCU API to be available.  console=true
    Sleep  30s
    Check Syslog Collection Is Ongoing  ${VCU_OAM_IP}


Step7: Change Time Interval For Syslog Streaming VCU
    Log  Step7: Change Time Interval for Syslog Streaming vCU  console=true
    ${syslog_streaming_parameters}  Catenate  SEPARATOR=,  \\"server\\":\\"${SYSLOG_SERVER_HOST}\\"  \\"port\\":514  \\"protocol\\":\\"UDP\\"
    ...  \\"format\\":\\"RFC5424\\"  \\"dscp\\":${DSCP}  \\"duration\\":2
    Run M2M Command  PUT  https://${VCU_OAM_IP}/api/licensed/v1/syslog-streaming  Bearer  ${TOKEN}  -d "{${syslog_streaming_parameters}}"
    Check Time Is Updated  ${VCU_OAM_IP}  2
    Check Syslog Collection Is Ongoing  ${VCU_OAM_IP}
    Wait Syslog Collection To Be Finnished  ${VCU_OAM_IP}  ${SYSLOG_COLLECTION_TIME}m
    ssh.Execute  sudo chmod 444 /var/log/remote_logs/BTS_Syslog_${VCU_OAM_IP}.log  connection=syslog_server
    ${ls_output}  ssh.Execute  ls -l /var/log/remote_logs  connection=syslog_server
    ${lines}  Get Lines Containing String  ${ls_output}  BTS_Syslog_${VCU_OAM_IP}.log
    Should Contain  ${lines}  r--r--r--  Coudn't grant reading permissions to BTS_Syslog_${VCU_OAM_IP}.log file.[NOK]
    ssh.Download File  /var/log/remote_logs/BTS_Syslog_${VCU_OAM_IP}.log  ${TEST_RESULTS_DIR}/Syslogs/vDU_BTS_Syslog_${VCU_OAM_IP}.log
    ...  connection=syslog_server

    [Teardown]  Run Keywords
    ...  Logout Using M2M Interface  ${VCU_OAM_IP}
    ...  AND
    ...  Clear File Form Server  /var/log/remote_logs/BTS_Syslog_${VCU_OAM_IP}.log  syslog_server


Step8: Check Operation History VCU
    Log  Step8: Check operation history vCU  console=true
    ${operation_history}  vcu.Get Cu Operation History
    Check Operation History  ${operation_history}[created]  Start vCU/vDU remote syslog streaming  M2M


Step9: Check Cells Are Enabled
    Log  Step9: Check cells are enabled  console=true
    Log  Wait up to ${RECOVERY_TIMEOUT} for cells to be enabled after vCU reset.  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s
    ...  Check Cells Are Enabled


Check Time Is Updated
    [Arguments]  ${ip}  ${updated_time}

    ${m2m_output}  Run M2M Command  GET  https://${ip}/api/licensed/v1/syslog-streaming  Bearer  ${TOKEN}
    ${m2m_output}  Remove M2M Output Noise  ${m2m_output}
    ${m2m_output}  Evaluate  ${m2m_output}
    ${stream_params}  Get From Dictionary  ${m2m_output}  streamParams
    ${duration}  Get From Dictionary  ${stream_params}  duration
    Should Be Equal As Strings  ${updated_time}  ${duration}  msg=Time not updated for syslog streaming.


Check Operation History
    [Documentation]  Check operation history
    [Arguments]  ${operation_history_list}  ${operation_name}  ${operation_triggering_source}

    FOR  ${operation}  IN  @{operation_history_list}
        IF  '${operation}[name]' != '${operation_name}'  CONTINUE
        IF  '${operation}[triggering_source]' != '${operation_triggering_source}'  CONTINUE
        Log  Operation found in Operation History: \n\t ${operation}  console=true
        BREAK
    END


Check Cells Are Enabled
    ${cells_statuses}  vdu.Get Vdu Cells Status
    FOR  ${cell_statuses}  IN  @{cells_statuses}
        Should Be Equal As Strings  ${cell_statuses}[operational_state]  enabled  ignore_case=True
    END


TC Setup
    Common VCU Setup
    Common VDU Setup
    Modify Resource Search Order  KPI__CBTS__M2M_Remote_Syslog_Streaming_Reset_API


TC Teardown
    Common VDU Teardown
    Common VCU Teardown
