*** Settings ***
Documentation
...  This TC is checking PM files before and after vDU reset. The number of NR counters must be the same.
...  PM reporting interval is set to 5min.

Resource  ../../common_resources/vdu_frame.robot
Resource  ../resources/PM_general.robot


*** Variables ***
${VDU_RECOVERY_TIMEOUT}  900s  # Timeout for VDU to be onAir
${NR_COUNTERS_MATCH}  M55  # It can be string or list of strings delimited by commas. They are counters prefix, e.g: M55 or M551,M552.


*** Keywords ***
TC__PM__vDU__NR_Counters_Check_After_Vdu_Reset
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28942
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 17.03.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28942 - TC creation
    ...  - 24.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29610 - Refactor pod name construction
    ...  - 05.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30163 - Fix sending fail messages

    Set Tags  CA-PM  OWNER-mohamad.al_hamwi@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com  GROUP_IN_CHARGE-TIM_1_Vrf  FEATURE-CB009746

    Step0: TC Prerequisites
    Step1: Set Initial NR Counters Number
    Step2: Perform Vdu Reset
    Step3: Check NR Counters Number After Site Reset


Step0: TC Prerequisites
    ${rep_interval_value}  VDU Get Parameter Value  reportingIntervalPm  MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
    IF  '${rep_interval_value}'!='5min'  Change specific parameter for vDU  reportingIntervalPm  5min  MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
    Sleep Until New Cycle  5min
    Sleep  1min  TC will wait until PM report is loaded.
    Open SSH Connection To VDU And Connect To Openshift
    ${oampm_pod_name}  Get Full Name For Pod  ${VDU_CRAN}  oampm
    ${oampm_container_name}  Get Full Name For Container  ${VDU_CRAN}  oampm
    Set Test Variable  ${OAMPM_POD_NAME}
    Set Test Variable  ${OAMPM_CONTAINER_NAME}

    [Teardown]  SSHLibrary.Close Connection


Step1: Set Initial NR Counters Number
    Log  \nStep1: Set Initial NR Counters Number  console=true
    ${last_pm_file_line}  Get Last File From PM Report Files From Vdu
    ${last_pm_file}  Remove String  ${last_pm_file_line}[-1]  '

    Open SSH Connection To VDU And Connect To Openshift
    ${copy_pm_file_command}  Catenate  kubectl cp
    ...  ${VDU_CRAN}/${OAMPM_POD_NAME}:/mnt/services/SS_OAM/PMSTAT/pm_report_files/${last_pm_file} /var/home/core/${last_pm_file}
    ...  -c ${OAMPM_CONTAINER_NAME}
    SSHLibrary.Write  ${copy_pm_file_command}
    SSHLibrary.Read Until Prompt
    Wait Until Keyword Succeeds  1min  10s  SSHLibrary.File Should Exist  /var/home/core/${last_pm_file}

    SSHLibrary.Get File  /var/home/core/${last_pm_file}  ${TEST_RESULTS_DIR}/${last_pm_file}
    Run  gzip -d -c ${TEST_RESULTS_DIR}/${last_pm_file} > ${TEST_RESULTS_DIR}/Initial_PM_Report.xml
    Run  sed -i "s/></>\\n</g" ${TEST_RESULTS_DIR}/Initial_PM_Report.xml
    ${all_counters}  ${counters_set_on_0}  Get Counters Number Based On XML PM File  ${NR_COUNTERS_MATCH}  ${TEST_RESULTS_DIR}/Initial_PM_Report.xml

    Log  NR counters number: ${all_counters}.  console=true
    Log  NR counters set on 0: ${counters_set_on_0}.  console=true

    Set Test Variable  ${ALL_COUNTERS_INITIAL_NUMBER}  ${all_counters}
    Set Test Variable  ${COUNTERS_SET_ON_0_INITIAL_NUMBER}  ${counters_set_on_0}
    Set Test Variable  ${PM_REPORT_BEFORE_RESET}  ${last_pm_file}

    [Teardown]  Run Keywords  SSHLibrary.Execute command  rm /var/home/core/${last_pm_file}  AND  SSHLibrary.Close Connection
    ...  AND  Run  rm ${TEST_RESULTS_DIR}/${last_pm_file}


Step2: Perform Vdu Reset
    Log  \nStep2: Perform Vdu Reset  console=true
    Reset VDU And Wait For Ping
    Wait Until Keyword Succeeds  ${VDU_RECOVERY_TIMEOUT}  10s  Check All Cells From VDU  availability_status=${ONLINE}  operational_state=${ENABLED}


Step3: Check NR Counters Number After Site Reset
    Log  \nStep3: Check NR Counters Number After Site Reset  console=true
    Sleep Until New Cycle  5min
    Sleep  1min  TC will wait until PM report is loaded.
    ${last_pm_file_line}  Get Last File From PM Report Files From Vdu
    ${last_pm_file}  Remove String  ${last_pm_file_line}[-1]  '
    Should Not Be Equal As Strings  ${last_pm_file}  ${PM_REPORT_BEFORE_RESET}  There is no new PM report generated.

    Open SSH Connection To VDU And Connect To Openshift
    ${copy_pm_file_command}  Catenate  kubectl cp
    ...  ${VDU_CRAN}/${OAMPM_POD_NAME}:/mnt/services/SS_OAM/PMSTAT/pm_report_files/${last_pm_file} /var/home/core/${last_pm_file}
    ...  -c ${OAMPM_CONTAINER_NAME}
    SSHLibrary.Write  ${copy_pm_file_command}
    SSHLibrary.Read Until Prompt
    Wait Until Keyword Succeeds  1min  10s  SSHLibrary.File Should Exist  /var/home/core/${last_pm_file}

    SSHLibrary.Get File  /var/home/core/${last_pm_file}  ${TEST_RESULTS_DIR}/${last_pm_file}
    Run  gzip -d -c ${TEST_RESULTS_DIR}/${last_pm_file} > ${TEST_RESULTS_DIR}/PM_Report_After_Vdu_Reset.xml
    Run  sed -i "s/></>\\n</g" ${TEST_RESULTS_DIR}/PM_Report_After_Vdu_Reset.xml
    ${all_counters}  ${counters_set_on_0}  Get Counters Number Based On XML PM File  ${NR_COUNTERS_MATCH}
    ...  ${TEST_RESULTS_DIR}/PM_Report_After_Vdu_Reset.xml

    Log  NR counters number after vDU reset: ${all_counters}.  console=true
    Log  NR counters set on 0 after vDU reset: ${counters_set_on_0}.  console=true

    ${total_number_is_different}  Run Keyword And Return Status  Should Not Be Equal As Integers  ${all_counters}
    ...  ${ALL_COUNTERS_INITIAL_NUMBER}
    IF  ${total_number_is_different}
        ${counters_diff}  Get Counters Differences Between 2 XML Files  ${TEST_RESULTS_DIR}/PM_Report_After_Vdu_Reset.xml
        ...  ${TEST_RESULTS_DIR}/Initial_PM_Report.xml  ${NR_COUNTERS_MATCH}  all
        Append To List  ${FAIL_MESSAGES}  Number of all NR counters is different. Following counters differ: ${counters_diff}.
        IF  '${TEST_VERDICT}'!='FAIL'  Set Test Variable  ${TEST_VERDICT}  FAIL
    END

    ${counters_on_0_are_different}  Run Keyword And Return Status  Should Not Be Equal As Integers  ${counters_set_on_0}
    ...  ${COUNTERS_SET_ON_0_INITIAL_NUMBER}
    IF  ${counters_on_0_are_different}
        ${counters_diff}  Get Counters Differences Between 2 XML Files  ${TEST_RESULTS_DIR}/PM_Report_After_Vdu_Reset.xml
        ...  ${TEST_RESULTS_DIR}/Initial_PM_Report.xml  ${NR_COUNTERS_MATCH}  set_on_0
        Log  Number of NR counters set on 0 is different. Following counters differ: ${counters_diff}.  level=WARN
    END

    [Teardown]  Run Keywords  SSHLibrary.Execute command  rm /var/home/core/${last_pm_file}  AND  SSHLibrary.Close Connection
    ...  AND  Run  rm ${TEST_RESULTS_DIR}/${last_pm_file}


Get Counters Number Based On XML PM File
    [Documentation]  This KW returns the numbers for all counters and counters set on 0 based on xml file and counters_match for NR technology.
    [Arguments]  ${counters_match}  ${pm_xml_path}

    ${counters_match}  Replace String  ${counters_match}  ,  |
    ${counters_match}  Remove String  ${counters_match}  ${SPACE}

    ${all_counters_command}  Catenate  grep -E "<(${counters_match})" ${pm_xml_path} | grep -iv "<MO dimension" | cut -d":" -f1 | sort | uniq -c
    ${counters_set_on_0_command}  Catenate  grep -E "<(${counters_match})" ${pm_xml_path} | grep -iv "<MO dimension" |
    ...  grep -e ">0<\\/M" | cut -d":" -f1 | sort | uniq -c
    ${all_counters}  Run  ${all_counters_command}
    ${counters_set_on_0}  Run  ${counters_set_on_0_command}

    ${counters_number}  Get Number Of Unique Counters  ${all_counters}
    ${counters_set_on_0}  Get Number Of Unique Counters  ${counters_set_on_0}

    RETURN  ${counters_number}  ${counters_set_on_0}


Get Number Of Unique Counters
    [Documentation]  This KW is counting unique counters within < > brackets from counters lines provided by grep command.
    [Arguments]  ${counters_lines}

    ${counters}  Get Regexp Matches  ${counters_lines}  <M[0-9A-Z]+>
    ${counters}  Remove Duplicates  ${counters}
    ${counters_number}  Get Length  ${counters}

    RETURN  ${counters_number}


Get Counters Differences Between 2 XML Files
    [Documentation]  This KW is returning a list of counters which represents counters differences between provided 2 xml files from virtual machine.
    ...  The last argument ${counters_type} can be 'all' or 'set_on_0' and grep command is set accordingly.
    [Arguments]  ${first_xml_file}  ${second_xml_file}  ${counters_match}  ${counters_type}

    ${last_commands}  Set Variable  grep -iv "<MO dimension"
    ${last_commands}  Set Variable If  '${counters_type}'=='all'  ${last_commands}  ${last_commands} | grep -e ">0<\\/M"
    ${last_commands}  Set Variable  ${last_commands} | cut -d":" -f1 | sort | uniq -c

    ${first_xml_counters_lines}  Run  grep -E "<(${counters_match})" ${first_xml_file} | ${last_commands}
    ${first_xml_counters}  Get Regexp Matches  ${first_xml_counters_lines}  <M[0-9A-Z]+>

    ${second_xml_counters_lines}  Run  grep -E "<(${counters_match})" ${second_xml_file} | ${last_commands}
    ${second_xml_counters}  Get Regexp Matches  ${second_xml_counters_lines}  <M[0-9A-Z]+>

    ${counters_diff}  Evaluate  list(set($first_xml_counters) ^ set($second_xml_counters))

    RETURN  ${counters_diff}


TC Setup
    Set Test Variable  ${TEST_VERDICT}  PASS
    ${FAIL_MESSAGES}  Create List
    Set Test Variable  ${FAIL_MESSAGES}
    Common VDU Setup
    Modify Resource Search Order  PM__vDU__NR_Counters_Check_After_Vdu_Reset


TC Teardown
    IF  '${TEST_VERDICT}'=='FAIL'
        FOR  ${msg}  IN  @{FAIL_MESSAGES}
            Fail  ${msg}
        END
        Set Test Variable  ${TEST_STATUS}  FAIL
    END
    Common VDU Teardown