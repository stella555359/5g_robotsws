*** Settings ***
Documentation
...  This test case is monitoring PPM OMES files creation. SBTS must have LTE deployed.
...  Parameters setting:
...      - reportingIntervalPm=15min
...      - mtCellAvailability=15min
...      - actPartialPmReportFile=true
...      - activeBulkPmReportingFormat=3GPP_OMeS
...  First check: PPM file must be created every 1 minute after the previous file is deleted in
...  /ffs/run/logs/oam/pmstat/ppm_omes location. PPM file creation and M8020C3 counter value are checked for 7 minutes.
...  Second and third checks: PPM file right before Site Reset and PDU Power Reset is saved and it must be transferred
...  to NetAct after reset operations.
...  In the end, syslog is parsed for verifying PPM files transfer success logs.

Resource  ../../common_resources/ca_PM_general.robot


*** Variables ***
${RESTORE_TIMEOUT}  1200  #Time for SBTS to reach on air state after reset.


*** Keywords ***
TC__PM__PPM_File_Transfer_To_Mantaray
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-30001
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 08.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30001 - Initial TAT creation
    ...  - 20.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30228 - Fix passing parameters
    ...  - 11.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30318 - Increase executions number for checking new PPM file is created
    ...                                                                     after site reset
    ...  - 19.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30356 - Add faults for watchdog
    ...  - 08.01.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30363 - Increase waiting time for new PPM report
    ...  - 18.03.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30653 - Fix PPM file not generated in previous reporting interval

    Set Tags  CA-PM  OWNER-mohamad.al_hamwi@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com  GROUP_IN_CHARGE-TIM_1_Vrf
    ...  FEATURE-CB013879

    Step0: TC Preconditions
    Step1: Check PPM File Is Generated Every 1 Minute And Check M8020C3 Value
    Step2: Perform Site Reset And Save PPM File To Be Checked In Syslog
    Step3: Perform BTS Power Reset And Save PPM File To Be Checked In Syslog


Step0: TC Preconditions
    Set Parameter To New Value  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMCADM-1  reportingIntervalPm  15min
    ${lnbts_id}  Admin Get LNBTS ID
    Set Parameter To New Value  MRBTS-${BTS_ID}/LNBTS-${lnbts_id}/PMRNL-1  mtCellAvailability  15min
    IF  ${SCF_COUNT_NR}
        ${nrbts_id}  Admin Get NRBTS ID
        Set Parameter To New Value  MRBTS-${BTS_ID}/NRBTS-${nrbts_id}/NRPMRNL-1  miNrCellAvailability  15min
    END
    Set Parameter To New Value  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1  actPartialPmReportFile  true
    Set Parameter To New Value  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMCADM-1  activeBulkPmReportingFormat  3GPP_OMeS
    Set Test Variable  ${PATH_TO_PPM_OMES_FILES}  /ffs/run/logs/oam/pmstat/ppm_omes


Step1: Check PPM File Is Generated Every 1 Minute And Check M8020C3 Value
    Log  \nStep1: Check PPM File Is Generated Every 1 Minute And Check M8020C3 Value   console=true
    Sleep Until New Cycle  minutes_for_cycle=15min
    Wait For New 1 Minute Interval
    Sleep  35s  TC waits for new PPM file to be generated.
    Open Connection To Primary Core
    ${current_ppm_file}  Wait Until Keyword Succeeds  10s  1s  Get PPM File Not Empty  ${PATH_TO_PPM_OMES_FILES}  PPM.*
    ${length}  Get Length  ${current_ppm_file}
    IF  ${length}>1  Fail  There are more than one PPM files generated when new 15 min interval starts.
    SSHLibrary.Get File  ${PATH_TO_PPM_OMES_FILES}/${current_ppm_file}[0]  ${BTS_FILES}/${current_ppm_file}[0]
    Check M8020C3 Value  ${BTS_FILES}/${current_ppm_file}[0]  60
    Log  PPM file is generated as expected after 1 minute and M8020C3 is 60.  console=true
    ${counter_value}  Set Variable  120
    FOR  ${index}  IN RANGE  2  8
        Wait For New 1 Minute Interval
        ${new_ppm_file}  Wait Until Keyword Succeeds  40s  8s  Wait For New PPM File To Be Generated  ${PATH_TO_PPM_OMES_FILES}  ${current_ppm_file}
        ...  ${index} minutes  PPM.*
        ${new_file_is_not_generated}  Run Keyword And Return Status  Lists Should Be Equal  ${new_ppm_file}  ${current_ppm_file}
        IF  ${new_file_is_not_generated}  Fail  There is no new PPM file generated as expected after ${index} minutes from current interval.
        ${current_ppm_file}  Set Variable  ${new_ppm_file}
        SSHLibrary.Get File  ${PATH_TO_PPM_OMES_FILES}/${new_ppm_file}[0]  ${BTS_FILES}/${new_ppm_file}[0]
        Check M8020C3 Value  ${BTS_FILES}/${new_ppm_file}[0]  ${counter_value}
        Log  PPM file is generated as expected after ${index} minutes and M8020C3 is ${counter_value}.  console=true
        ${counter_value}  Evaluate  ${counter_value}+60
    END

    [Teardown]  Run Keywords  SSHLibrary.Close Connection  AND  Run Keyword And Ignore Error  Run  rm ${BTS_FILES}/*.gz


Step2: Perform Site Reset And Save PPM File To Be Checked In Syslog
    Log  \nStep2: Perform Site Reset And Save PPM File To Be Checked In Syslog  console=true
    Sleep Until New Cycle  minutes_for_cycle=15min
    Open Connection To Primary Core
    ${last_ppm_file_previous_interval}  Wait Until Keyword Succeeds  140s  2s  Get PPM File Not Empty  ${PATH_TO_PPM_OMES_FILES}  PPM.*
    Wait For New 1 Minute Interval
    ${ppm_file}  Wait Until Keyword Succeeds  40s  10s  Wait For New PPM File To Be Generated  ${PATH_TO_PPM_OMES_FILES}
    ...  ${last_ppm_file_previous_interval}  1 minute  PPM.*

    Log  Perform Site Reset...  console=true
    coam.Reset Site  timeout=600  wait_for_reconnection=False

    ${ping_is_lost}  Run Keyword And Return Status  Wait For Target To Be Not Reachable  hostname=${OAM_BTS_IP}  timeout=5
    ${no_of_iterations}  Set Variable  0
    WHILE  not ${ping_is_lost} and ${no_of_iterations} < 5
        ${status}  ${next_ppm_file}  Run Keyword And Ignore Error  Wait Until Keyword Succeeds  60s  2s
        ...  Wait For New PPM File To Be Generated  ${PATH_TO_PPM_OMES_FILES}  ${ppm_file}  Site Reset  PPM.*
        ${ppm_file}  Set Variable If  '${status}'=='PASS'  ${next_ppm_file}  ${ppm_file}
        ${ping_is_lost}  Run Keyword And Return Status  Wait For Target To Be Not Reachable  hostname=${OAM_BTS_IP}  timeout=30
        ${no_of_iterations}  Evaluate  ${no_of_iterations}+1
    END
    Log  Ping to primary core is lost after Site Reset.  console=true

    Wait For Target To Be Reachable  hostname=${OAM_BTS_IP}  timeout=300
    Log  Primary core is reachable after Site Reset.  console=true
    ${time_after_site_reset}  Get Current Date  UTC  result_format=%Y-%m-%d %H:%M:%S.%f
    Set Test Variable  ${TIME_AFTER_SITE_RESET}

    Open Connection To Primary Core
    ${ppm_file_after_site_reset}  Wait Until Keyword Succeeds  10s  2s  Get PPM File Not Empty  ${PATH_TO_PPM_OMES_FILES}  PPM.*
    Lists Should Be Equal  ${ppm_file}  ${ppm_file_after_site_reset}  There is new PPM file generated right after Site Reset.
    Log  ${ppm_file}[0] is still visible after Site Reset and will be checked in syslog.  console=true
    Set Test Variable  ${PPM_REPORT_AFTER_SITE_RESET}  ${ppm_file}[0]

    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT}  30s  Admin Check All Required State
    Log  SBTS is on Air after Site Reset.  console=true

    [Teardown]  SSHLibrary.Close Connection


Step3: Perform BTS Power Reset And Save PPM File To Be Checked In Syslog
    Log  \nStep3: Perform BTS Power Reset And Save PPM File To Be Checked In Syslog  console=true
    Sleep Until New Cycle  minutes_for_cycle=15min
    Open Connection To Primary Core
    ${last_ppm_file_previous_interval}  Wait Until Keyword Succeeds  140s  2s  Get PPM File Not Empty  ${PATH_TO_PPM_OMES_FILES}  PPM.*
    Wait For New 1 Minute Interval
    ${ppm_file}  Wait Until Keyword Succeeds  40s  15s  Wait For New PPM File To Be Generated  ${PATH_TO_PPM_OMES_FILES}
    ...  ${last_ppm_file_previous_interval}  1 minute  PPM.*
    SSHLibrary.Close Connection

    Log  Perform PDU Power Reset...  console=true
    ${serial_number}  Get Primary Core Serial Number
    Pdu BTS Interface Off  SMOD_${serial_number}
    Wait For Target To Be Not Reachable  hostname=${OAM_BTS_IP}  timeout=300
    Log  Ping to primary core is lost.  console=true

    Pdu BTS Interface On  SMOD_${serial_number}
    Wait For Target To Be Reachable  hostname=${OAM_BTS_IP}  timeout=300
    Log  Primary core is reachable after PDU Power Reset.  console=true
    ${time_after_pdu_power_reset}  Get Current Date  UTC  result_format=%Y-%m-%d %H:%M:%S.%f
    Set Test Variable  ${TIME_AFTER_PDU_POWER_RESET}

    Wait Until Keyword Succeeds  120  20s  Open Connection To Primary Core
    ${ppm_file_after_power_reset}  Wait Until Keyword Succeeds  10s  2s  Get PPM File Not Empty  ${PATH_TO_PPM_OMES_FILES}  PPM.*
    Lists Should Be Equal  ${ppm_file}  ${ppm_file_after_power_reset}  There is new PPM file generated right after PDU Power Reset.
    Log  ${ppm_file}[0] is still visible after PDU Power Reset and will be checked in syslog.  console=true
    Set Test Variable  ${PPM_REPORT_AFTER_POWER_RESET}  ${ppm_file}[0]

    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT}  30s  Admin Check All Required State
    Log  SBTS is on Air after PDU power off/on.  console=true

    [Teardown]  SSHLibrary.Close Connection


Check PM Reports In Syslog
    Log  \nCheck PM Reports In Syslog  console=true
    Unarchive Syslogs From UDPLogs Directory
    ${syslog_file}  Set Variable  ${UDP_LOGS}/Unarchived/SYSLOG_PC_UDP

    Check PM Report In Syslog  ${PPM_REPORT_AFTER_SITE_RESET}  ${syslog_file}  ${TIME_AFTER_SITE_RESET}
    Check PM Report In Syslog  ${PPM_REPORT_AFTER_POWER_RESET}  ${syslog_file}  ${TIME_AFTER_PDU_POWER_RESET}

    [Teardown]  Delete Unarchived Syslogs From UDPLogs Directory


Check M8020C3 Value
    [Arguments]  ${path_to_ppm_gz_file}  ${counter_value}

    ${path_to_ppm_xml_file}  Remove String  ${path_to_ppm_gz_file}  .gz
    Run  gzip -d -c ${path_to_ppm_gz_file} > ${path_to_ppm_xml_file}
    Run  sed -i "s/></>\\n</g" ${path_to_ppm_xml_file}
    ${counter_lines}  Run  grep -E "<M8020C3>" ${path_to_ppm_xml_file}
    ${counter_lines}  Split To Lines  ${counter_lines}
    Should Not Be Empty  ${counter_lines}  M8020C3 is not visible in PPM report ${path_to_ppm_xml_file}.
    FOR  ${line}  IN  @{counter_lines}
        Should Contain  ${line}  >${counter_value}<  M8020C3 has unexpected value in PPM report ${path_to_ppm_xml_file}.
    END


TC Setup
    Common Test Setup  tc_name=PM__PPM_File_Transfer_To_Mantaray


TC Teardown
    Common Test Teardown
    Check PM Reports In Syslog
