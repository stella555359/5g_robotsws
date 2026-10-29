*** Settings ***
Documentation
    ...  Test case will verify that fault signature fields are populated in the alarm raised for FID 1907 on various radio releases and families.
    ...  First, actFaultSignature is set to true and radio module is chosen.
    ...  Radio module information is extracted and site reset is performed.
    ...  After site reset, connection to radio module is opened and fault is triggered.
    ...  Radio autonomous reset alarm must must be reported 3 times in WebEM and NetAct.
    ...  Fault signature fields for radio autonomous reset alarm must be populated correctly.
    ...  Unit recovery reset counter is incremented automatically 3 times and the radio module remains with critical fault 1907 "TX out of order".
    ...  At the end of the test, radio module is recovered by sendind a recovery command and SBTS must be on air.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${STARTUP_TIMEOUT}  1200  # Timeout for SBTS to recover after site reset
${ALARM_TIMEOUT}  600  # Timeout for alarms to appear
${RECOVERY_TIMEOUT}  900  # Timeout for SBTS to recover after radio recovery reset
${BLOCK_TIMEOUT}  300  # Timeout for cell to become blocked or unblocked
${RMOD_TYPE}  ${EMPTY}  # [Mandatory] RMOD product name.
${RUNTIME_TIMEOUT}  260  # Timeout between triggering next radio reset with fid 1907


*** Keywords ***
FM__RMOD_reset_counter_exceeded_FID1907
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-23831
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  03.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23831 - Initial TAT creation
    ...  14.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24109 - Give correct arguments to keyword
    ...  17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  12.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25370 - Remove BTS_L_ID
    ...  31.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25478 - Update FM testcases for actFaultSignature
    ...  26.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25598 - Test fails when checking extra_info field from fault signature
    ...  03.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26021 - Change the selection of RMOD
    ...  15.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25658 - Create new resources for NetAct and ONAP KWs
    ...  19.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26405 - Triggering fault method changed
    ...  22.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26638 - RF does not find expected prompt
    ...  11.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26690 - Fix the search for RMOD IP
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  03.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27195 - Handling multiple cases for RMOD connection prompt
    ...  04.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27602 - Added option for 7.1 RMOD generation
    ...  17.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27606 - Multiple keywords for checking fault signature in FM testcases
    ...  13.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28083 - Change RMOD reset method for alarm clearance
    ...  30.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28027 - Add check for 4241-4247 faults in Raw Alarm History
    ...  27.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28144 - Add sleep before every crash command
    ...  31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  05.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28298 - Bug fix for TAT-28298
    ...  07.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28341 - Test fails when checking fault in rawAlarmHistory
    ...  04.12.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28378 - Test fails when checking fault signature in Netact
    ...  17.01.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-27777 - Implementation of the method for 7.1 RMOD generation
    ...  28.01.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28673 - Test fails at setting the test preconditions
    ...  18.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28703 - Add check for faults 1907 and 4003
    ...  22.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29213 - Replace RMOD info search from /rom/config/FRIps.txt
    ...  27.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29366 - Enhancement for CB008708
    ...  04.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29516 - Skip CB008708 for software versions below 25R3
    ...  01.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28763 - Created radio modules data file and new RMOD connection method
    ...  22.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29741 - Update retrieval method of RMOD credentials
    ...  29.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29780 - Add timeout between triggering next radio reset with fid 1907
    ...  26.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29911 - Generalized recovery execution result variable for master side
    ...  07.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29974 - Set actForceUnitAutoReset parameter to False
    ...  02.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30000 - Add check for fault 4003 supplementary alarm info
    ...  16.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30319 - Added maintenance window cleanup in case the test failed
    ...  06.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-29500 - Enhancement to skip check for fault 4003
    ...  10.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30468 - Added RFSW access rights for the RMOD SSH, removed an unused variable
    ...  19.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30515 - Updated the method parameters used for 7_1 fault generation
    ...  19.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30539 - Test fails because fault is not sent on slave ips
    ...  ******************

    Set Tags  CA-FM  OWNER-alina.cret@nokia.com  AUTHOR-anna.benzar@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS22  FEATURE-CB007273

    Step0: Test Case Preconditions
    Step1: Perform Site Reset
    Step2: Trigger Fault On RMOD For 3 Times
    Step3: Trigger Fault On RMOD For 4th Time
    Step4: Verify Alarms And Fault Signature In WebEm And NetAct
    Step5: Activate Maintenance Window
    Step6: Deactivate Maintenance Window
    Step7: Recover Faulty RMOD
    Step8: Verify Faults Presence In RawAlarmHistory File


Step0: Test Case Preconditions
    Log  \nStep0: Setting test case preconditions.  console=true

    Should Not Be Empty  ${RMOD_TYPE}  The RMOD_TYPE variable is not set correctly. [NOK]

    ${rmod_side}  ${rmod_ip}  ${stored_role}  ${rmod_sn}  Set RMOD Parameters By RMOD Type  ${RMOD_TYPE}
    ${rmods_list}  coam.Get Frm
    FOR  ${rmod}  IN  @{rmods_list}
        IF  '${rmod}[serialNumber]' == '${rmod_sn}'
            ${rmod_object}  Set Variable  ${rmod}
            BREAK
        END
    END
    ${rmod_distname}  Set Variable  ${rmod_object}[id][internal]
    ${cells_on_rmod}  Get Cell Mapping By Module Id  ${rmod_distname}
    ${chosen_cell_on_rmod}  Evaluate  random.choice(${cells_on_rmod})  modules=random
    Set Test Variable  ${CELL_ON_RMOD}  ${chosen_cell_on_rmod}
    Set Test Variable  ${RMOD_SIDE}  ${rmod_side}
    Set Test Variable  ${RMOD_IP}  ${rmod_ip}
    Set Test Variable  ${RMOD_SN}  ${rmod_sn}
    Set Test Variable  ${RMOD_R_DN}  ${rmod_distname}
    Set Test Variable  ${STORED_ROLE}  ${stored_role}
    ${sw_line}  Get SW Line For Specific RMOD  ${RMOD_R_DN}
    ${username}  ${password}  Get User And Password For RMOD  ${sw_line}  ${RMOD_TYPE}
    ${hw_generation}  Get Hw Generation For RMOD  ${RMOD_TYPE}
    Set Test Variable  ${RMOD_USERNAME}  ${username}
    Set Test Variable  ${RMOD_PASSWORD}  ${password}

    IF  '${hw_generation}' == '7.1'
        Set Test Variable  ${METHOD_7_1_GENERATION}  ${TRUE}
    ELSE
        Set Test Variable  ${METHOD_7_1_GENERATION}  ${FALSE}
    END

    Change FEATCADM Parameter  actFaultSignature  true
    Set Test Variables For Test
    Change FMCADM Parameter  actForceUnitAutoReset  false


Step1: Perform Site Reset
    Log  \nStep1: Performing Site Reset to clear all counters.  console=true
    Perform Site Reset


Step2: Trigger Fault On RMOD For 3 Times
    Log  \nStep2:Trigger fault on RMOD for 3 times.  console=true
    IF  ${METHOD_7_1_GENERATION}
        Repeat Keyword  3  Sending Fault To 7_1 Generation RMOD And Checking RMOD Status  ${DISABLED}
    ELSE
        FOR  ${loop}  IN RANGE  0  3
            Sending Fault And Checking RMOD Status  ${DISABLED}
            ${time_difference}  Get Time Difference Between Fault 1907 Major And Warning
            IF  ${time_difference}<10
                Log  Time difference is under 10sec : ${time_difference} sec. Presence of fault 4003 will be not checked.  console=true
            ELSE
                Log  Time difference is greater than 10sec : ${time_difference} sec. Presence of fault 4003 will be checked.  console=true
                IF  ${STATUS_4003}
                    Log  Fault 4003 was raised.  console=true
                ELSE
                    Fail  Fault 4003 not present or alarm information incorrect.
                END
            END
        END
    END


Step3: Trigger Fault On RMOD For 4th Time
    Log  \nStep3: Trigger fault on RMOD for 4th time.  console=true
    IF  ${METHOD_7_1_GENERATION}
        Sending Fault To 7_1 Generation RMOD And Checking RMOD Status  ${ENABLED}  ${DEGRADED}
    ELSE
        Sending Fault And Checking RMOD Status  ${ENABLED}  ${DEGRADED}
    END


Step4: Verify Alarms And Fault Signature In WebEm And NetAct
    Log  \nStep4: Verifying alarms and fault signature in WebEm and NetAct.  console=true
    Log  Verifying Radio autonomous reset alarm 3 times.  console=true
    Check Alarm In WebEm And NetAct And Fault Signature In NetAct
    ${current_date}  Get Current Date  result_format=%Y%m%d
    ${rmod_sn_list}  Create List  ${RMOD_SN}
    Check Fault Signature In WebEM For All Radio Modules  ${FAULT_1907_RADIO_AUTO_RST}[fault_id]  ${FAULT_1907_RADIO_AUTO_RST}[severity]
    ...  ${rmod_sn_list}  1  ${CATEGORY}  ${SCOPE}  ${EXTRA_INFO}  ${SW_VERSION}  ${current_date}
    Log  Verifying TX out of order alarm.  console=true
    Verify TX Out Of Order Alarm In Webem And NetAct


Step5: Activate Maintenance Window
    IF  '${ENB_BRANCH}' < 'SBTS25R3'  RETURN
    Log  \nStep5: Activate Maintenance Window.  console=true
    Create Maintenance Window
    Wait Until Keyword Succeeds  900s  10s
    ...  Assert  RMOD  ${RMOD_R_DN}  parameters=operationalState=${ENABLED}
    Wait Until Keyword Succeeds  900s  10s
    ...  Check All Cells

    ${rmod_r_dn_mw}  Fetch From Right  ${RMOD_R_DN}  /EQM_R-
    ${recovery_execution_result}  Set Variable  Radio recovery reset:MRBTS-${BTS_ID}/EQM_R-${rmod_r_dn_mw}
    ${parameter_object}  Wait Until Keyword Succeeds  300  10  Get Forced Recovery Parameter When Is Completed
    Verify Force Recovery Parameters  ${parameter_object}  ${FAULT_1907_TX_OUT_OF_ORDER}  recovery_execution_result=${recovery_execution_result}


Step6: Deactivate Maintenance Window
    IF  '${ENB_BRANCH}' < 'SBTS25R3'  RETURN
    Log  \nStep6: Deactivate Maintenance Window.  console=true
    Delete Maintenance Window


Step7: Recover Faulty RMOD
    Log  \nStep7: Recovering faulty RMOD.  console=true
    IF  ${METHOD_7_1_GENERATION}
        Perform Site Reset
    ELSE
        Open Connection To Radio Module  ${RMOD_SIDE}  ${STORED_ROLE}  ${RMOD_IP}  ${RMOD_USERNAME}  ${RMOD_PASSWORD}
        Send Recovery Command On Rmod
        Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  20  Check Modules And Cells
        Perform Site Reset
    END


Step8: Verify Faults Presence In RawAlarmHistory File
    Log  \nStep8: Verify Faults Presence In RawAlarmHistory File.  console=true
    FOR  ${fault_id}  IN  @{EXPECTED_FAULTS_RAW}
       ${fault_status}  Run Keyword And Return Status  Verify Alarm In RawAlarmHistory File  ${fault_id}  ${CURRENT_DATE_TIME_RAW}
       IF  ${fault_status}  RETURN
    END
    Fail  No fault from ${EXPECTED_FAULTS_RAW} list reported in "RawAlarmHistory" file on current date, after ${CURRENT_DATE_TIME_RAW}. [NOK]


Set Test Variables For Test
    ${start_time_webem}  Get BTS time in UTC format  %Y-%m-%d %H:%M:%S.%6N
    Set Test Variable  ${START_TIME_WEBEM}
    ${start_time_netact}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${START_TIME_NETACT}
    ${current_date_time_raw}  Get BTS time in UTC format  %Y-%b-%d %H:%M:%S
    Set Test Variable  ${CURRENT_DATE_TIME_RAW}
    ${expected_faults_raw}  Create List  4241  4242  4243  4244  4246  4247
    Set Test Variable  ${EXPECTED_FAULTS_RAW}
    Set Test Variable  ${CATEGORY}  SW_FAILURE
    Set Test Variable  ${SCOPE}  RFM
    Set Test Variable  ${EXTRA_INFO}  (faulty_cells|gracefully_shutdown_cells)?=.*NR:[0-9]+.*


Sending Fault And Checking RMOD Status
    [Arguments]  ${operational_status}  ${availability_status}=${EMPTY}

    Log  Triggering fault  console=true
    Open Connection To Radio Module  ${RMOD_SIDE}  ${STORED_ROLE}  ${RMOD_IP}  ${RMOD_USERNAME}  ${RMOD_PASSWORD}
    Send Fault On Rmod
    Check RMOD Status After Triggering Fault  ${operational_status}  ${availability_status}
    Sleep  ${RUNTIME_TIMEOUT}  Timeout between triggering next radio reset with fid 1907.


Sending Fault To 7_1 Generation RMOD And Checking RMOD Status
    [Arguments]  ${operational_status}  ${availability_status}=${EMPTY}

    Log  Triggering fault  console=true
    Open Connection To Radio Module  ${RMOD_SIDE}  ${STORED_ROLE}  ${RMOD_IP}  ${RMOD_USERNAME}  ${RMOD_PASSWORD}
    Sending Fault To 7_1 Generation Rmod
    Check RMOD Status After Triggering Fault  ${operational_status}  ${availability_status}
    Sleep  ${RUNTIME_TIMEOUT}  Timeout between triggering next radio reset with fid 1907.


Sending Fault To 7_1 Generation Rmod
    Log  Sending fault to 7_1 generation RMOD.  console=true

    SSHLibrary.Write  sudo su rfsw
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  sudo mount -o remount rw /mnt/factory
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  echo $'/ action create ConfigAccess /ca /module' | frmonShellClient 127.0.0.1 2000
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  echo $'/ca action fetch DECODED "gc.bin" "/ram/gc.json"' | frmonShellClient 127.0.0.1 2000
    SSHLibrary.Read Until Prompt
    SSHLibrary.write  cd /ram
    SSHLibrary.Read Until Prompt
    ${first_command}  Catenate  SEPARATOR=  sed -i -E ':a;N;$!ba;s/"fbLevelValidation":${SPACE}\\{[${SPACE}]*\\n[${SPACE}]*
    ...  "enable":${SPACE}true,/"fbLevelValidation":${SPACE}\\{\\n\\t"enable":${SPACE}false,/g' gc.json
    SSHLibrary.Write  sed -i -E ':a;N;$!ba;s/"fbMaxThreshold":${SPACE}-5.0,/"fbMaxThreshold":${SPACE}-50.0,/g' gc.json
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  ${first_command}
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  echo $'/ca action store DECODED "gc.bin" "/ram/gc.json"' | frmonShellClient 127.0.0.1 2000
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  echo $'/ca action update' | frmonShellClient 127.0.0.1 2000
    SSHLibrary.Read Until Prompt
    SSHLibrary.Close Connection
    Block Cell  dist_name=${CELL_ON_RMOD}  timeout=${BLOCK_TIMEOUT}
    Unblock Cell  dist_name=${CELL_ON_RMOD}  timeout=${BLOCK_TIMEOUT}


Send Fault On Rmod
    Log  Sending fault on rmod.  console=true
    IF  '${ENB_BRANCH}'>='SBTS26R2'
        SSHLibrary.Write  sudo -i
        SSHLibrary.Read Until Prompt
    END
    SSHLibrary.Write  ip -4 neigh
    ${output_command}  SSHLibrary.Read Until Prompt
    ${slave_ips}  Get Regexp Matches  ${output_command}  192.168.101.[0-9]+
    Sort List  ${slave_ips}
    ${ips_length}  Get Length  ${slave_ips}
    SSHLibrary.Write  sudo devmem 0xFC9003A4 32 0x0
    SSHLibrary.Read Until Prompt
    Sleep  15s  Wait to send next crash command.
    IF  '${ENB_BRANCH}'>='SBTS26R2'
        SSHLibrary.Write  sudo su rfsw
        SSHLibrary.Read Until Prompt
    END
    FOR  ${index}  ${ip}  IN ENUMERATE  @{slave_ips}
        SSHLibrary.Write  ssh ${ip}
        SSHLibrary.Read Until Prompt
        SSHLibrary.Write  sudo -i
        SSHLibrary.Set Client Configuration  prompt=REGEXP:(~#|\\$|\\n\\$)
        SSHLibrary.Read Until Prompt
        SSHLibrary.Write  sudo devmem 0xFC9003A4 32 0x0
        SSHLibrary.Read Until Prompt
        SSHLibrary.Write  exit
        SSHLibrary.Set Client Configuration  prompt=REGEXP:(~#|\\$|\\n\\$)
        SSHLibrary.Read Until Prompt
        SSHLibrary.Write  exit
        SSHLibrary.Read Until Prompt
        IF  ${index+1} == ${ips_length/2}
            Check Faults 1907 And 4003
        END
        Sleep  15s  Wait to send next crash command.
    END

    [Teardown]  SSHLibrary.Close Connection


Check Faults 1907 And 4003
    Log  Check fault 1907 with severity Major.  console=true
    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_1907_TX_OUT_OF_ORDER_MAJOR}
    Assert Alarm Active  parameters=${alarm_parameters}  timeout=60
    Log  Fault ${FAULT_1907_TX_OUT_OF_ORDER_MAJOR} is reported in WebEm.  console=true
    Sleep  5s  Waiting for channels state update.
    ${cells_with_4003}  Create List
    Append To List  ${cells_with_4003}  ${CELL_ON_RMOD}
    ${status_4003}  Run Keyword And Return Status  Check Fault 4003  ${cells_with_4003}
    Set Test Variable  ${STATUS_4003}


Get Time Difference Between Fault 1907 Major And Warning
    ${historical_alarms}  Get Historic Alarms
    Reverse List  ${historical_alarms}
    FOR  ${alarm}  IN  @{historical_alarms}
        ${condition_radio_auto_rst}  Catenate  SEPARATOR=${SPACE}and${SPACE}
        ...  '${alarm}[faultId]'=='${FAULT_1907_RADIO_AUTO_RST}[fault_id]'
        ...  '${alarm}[faultName]'=='${FAULT_1907_RADIO_AUTO_RST}[fault_name]'
        ...  '${alarm}[alarmId]'=='${FAULT_1907_RADIO_AUTO_RST}[alarm_id]'
        ...  '${alarm}[alarmName]'=='${FAULT_1907_RADIO_AUTO_RST}[alarm_name]'
        ...  '${alarm}[severity]'=='${FAULT_1907_RADIO_AUTO_RST}[severity]'
        ${condition_tx_out_of_order}  Catenate  SEPARATOR=${SPACE}and${SPACE}
        ...  '${alarm}[faultId]'=='${FAULT_1907_TX_OUT_OF_ORDER_MAJOR}[fault_id]'
        ...  '${alarm}[faultName]'=='${FAULT_1907_TX_OUT_OF_ORDER_MAJOR}[fault_name]'
        ...  '${alarm}[alarmId]'=='${FAULT_1907_TX_OUT_OF_ORDER_MAJOR}[alarm_id]'
        ...  '${alarm}[alarmName]'=='${FAULT_1907_TX_OUT_OF_ORDER_MAJOR}[alarm_name]'
        ...  '${alarm}[severity]'=='${FAULT_1907_TX_OUT_OF_ORDER_MAJOR}[severity]'
        IF  ${condition_radio_auto_rst}
            ${alarm_1907_radio_recovery}  Set Variable  ${alarm}
        ELSE IF  ${condition_tx_out_of_order}
            ${alarm_1907_tx_out_of_order}  Set Variable  ${alarm}
        END
    END
    ${observation_time_1907_tx}  Convert Timestamp From BtsObservationTime  ${alarm_1907_tx_out_of_order}[btsObservationTime]
    ${observation_time_1907_recovery}  Convert Timestamp From BtsObservationTime  ${alarm_1907_radio_recovery}[btsObservationTime]
    Log  Observation time_1907_tx_out_of_order: ${observation_time_1907_tx}  console=true
    Log  observation_time_1907__radio_recovery: ${observation_time_1907_recovery}  console=true
    ${time_difference}  Subtract Time From Time  ${observation_time_1907_recovery}  ${observation_time_1907_tx}
    ${time_difference}  Convert To Integer  ${time_difference}

    RETURN  ${time_difference}


Check RMOD Status After Triggering Fault
    [Arguments]  ${operational_status}  ${availability_status}=${EMPTY}

    ${rmod_status}  Set Variable If  '${availability_status}'=='${EMPTY}'  operationalState=${operational_status}
    ...  '${availability_status}'!='${EMPTY}'  operationalState=${operational_status}, availabilityStatus=${availability_status}
    Log  Check RMOD status to be ${operational_status} and ${availability_status}  console=true
    Wait Until Keyword Succeeds  900  10
    ...  Assert Any  RMOD  ${rmod_status}
    IF  '${availability_status}'==''
        Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  20  Check Modules And Cells
    ELSE
        Log  RMOD status is ${operational_status} and ${availability_status}  console=true
    END

Send Recovery Command On Rmod
    Log  Sending recovery command and closing connection.  console=true
    ${rmods}  Get Parameters For All  RMOD
    SSHLibrary.Write  rm -r /mnt/runtime/configs/*
    SSHLibrary.Read Until Prompt
    SSHLibrary.Close Connection
    FOR  ${rmod}  IN  @{rmods}
        IF  '${rmod}[serialNumber]'=='${RMOD_SN}'  BREAK
    END
    Reset Unit  ${rmod}[id]  timeout=300


Check Alarm In WebEm And NetAct And Fault Signature In NetAct
    Verify Radio Autonomous Reset Alarm In Webem And NetAct
    Log  \nChecking fault signature for alarm 1907 in NetAct.  console=True
    Wait Until Keyword Succeeds  300  10s
    ...  Check Fault Signature In Netact For Radio Recovery Reset Scenario  ${FAULT_1907_RADIO_AUTO_RST}[fault_id]
    ...  ${RMOD_SN}
    ...  ${CATEGORY}
    ...  ${SCOPE}
    ...  ${EXTRA_INFO}
    ...  ${SW_VERSION}
    ...  ${START_TIME_NETACT}
    Log  Fault signature correctlly filled in NetAct for fault ${FAULT_1907_RADIO_AUTO_RST}.  console=true


Verify Radio Autonomous Reset Alarm In Webem And NetAct
    Log  Fault ${FAULT_1907_RADIO_AUTO_RST}[fault_name] will be checked in Alarm History and should appear 3 times.  console=true
    ${historical_alarms}  Get Historic Alarms  load_history=true  timeout=60s
    ${no_of_alarms}  Set Variable  0
    FOR  ${alarm}  IN  @{historical_alarms}
        ${timestamp}  Fetch From Left  ${alarm.btsObservationTime}  +
        ${time}  Convert Date  ${timestamp}
        ${status_alarm}  Run Keyword And Return Status
        ...  Should Contain  ${alarm.alarmDetail}  ${FAULT_1907_RADIO_AUTO_RST}[fault_name]
        IF  '${time}'>'${START_TIME_WEBEM}' and ${status_alarm}
            ${no_of_alarms}  Set Variable  ${no_of_alarms} + 1
        ELSE
            CONTINUE
        END
    END
    IF  ${no_of_alarms} == 3
        Log  Fault ${FAULT_1907_RADIO_AUTO_RST} is visible in alarms history in WebEM for ${no_of_alarms} times.  console=true
    ELSE
        Fail  Fault ${FAULT_1907_RADIO_AUTO_RST} is not visible in alarms history in WebEM.
    END
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_1907_RADIO_AUTO_RST}  time_from=${START_TIME_NETACT}
    ...  additional_fault_id=${FAULT_1907_RADIO_AUTO_RST}[fault_id]
    Log  Fault ${FAULT_1907_RADIO_AUTO_RST} is reported and cleared in NetAct.  console=true


Verify TX Out Of Order Alarm In Webem And NetAct
    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_1907_TX_OUT_OF_ORDER}
    Assert Alarm Active  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_1907_TX_OUT_OF_ORDER} is reported in WebEm.  console=true
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_1907_TX_OUT_OF_ORDER}
    ...  additional_fault_id=${FAULT_1907_TX_OUT_OF_ORDER}[fault_id]
    Log  Fault ${FAULT_1907_TX_OUT_OF_ORDER} is reported in NetAct.  console=true


Recovery Action If Test Fails
    IF  ${METHOD_7_1_GENERATION}
        Maintenance Window Cleanup
        Perform Site Reset
    ELSE
        Recover Unit
        ...  Send Recovery Command On Rmod  ${RMOD_SIDE}  ${STORED_ROLE}  ${RMOD_IP}  ${RMOD_USERNAME}  ${RMOD_PASSWORD}
        Maintenance Window Cleanup
        Perform Site Reset
    END


TC Setup
    Common Test Setup  tc_name=FM__RMOD_reset_counter_exceeded_FID1907
    Setup NetAct


TC Teardown
    Run Keyword If Test Failed  Recovery Action If Test Fails
    SSHLibrary.Close All Connections
    Teardown NetAct
    Common Test Teardown
