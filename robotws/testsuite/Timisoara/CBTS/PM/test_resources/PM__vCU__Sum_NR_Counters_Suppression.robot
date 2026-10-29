*** Settings ***
Documentation
...  This TC is changing actZeroCounterSuppression parameter and verifies PMQAP and Non-PMQAP counters in PM reports.
...  actZeroCounterSuppression is set to 'NR non-PMQAP sum Counters', 'NR PMQAP sum Counters' and both 'NR PMQAP sum Counters' and
...  'NR PMQAP sum Counters'.
...  For each case, PMQAP or Non-PMQAP counters (depending on actZeroCounterSuppression value) may be missing, but in case they are visible in PM
...  reports, their value must not be equal to 0.
...  In the end, actZeroCounterSuppression is set to None.

Resource  ../../common_resources/vcu_frame.robot
Resource  ../resources/PM_general.robot


*** Variables ***
${EXPECTED_COUNTERS_PATH}  /home/ute/MN/UTE/robotws/testsuite/Timisoara/CBTS/PM/counters/Sum_NR_Counters_Suppression


*** Keywords ***
TC__PM__vCU__Sum_NR_Counters_Suppression
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29347
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 06.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29347 - TC creation
    ...  - 30.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29654 - Fix actZeroCounterSuppression last update
    ...  - 01.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29669 - Change test status in case fail messages exist
    ...  - 24.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29610 - Refactor pod name construction

    Set Tags  CA-PM  OWNER-mohamad.al_hamwi@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com  GROUP_IN_CHARGE-TIM_1_Vrf
    ...  CNI-137374  CNI-134957

    Step0: TC Prerequisites
    Step1: Set ActZeroCounterSuppression To Non-PMQAP
    Step2: Check NON_PMQAP Counters
    Step3: Set ActZeroCounterSuppression To PMQAP
    Step4: Check PMQAP Counters
    Step5: Set ActZeroCounterSuppression To Non-PMQAP And PMQAP
    Step6: Last Check For Non-PMQAP And PMQAP Counters


Step0: TC Prerequisites
    Change ActZeroCounterSuppression To None If Needed
    ${rep_interval_value}  VCU Get Parameter Value  reportingIntervalPm  MRBTS-${VCU_MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
    IF  '${rep_interval_value}'!='5min'  Change specific parameter for vCU  reportingIntervalPm  5min  MRBTS-${VCU_MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
    Sleep Until New Cycle  5min
    Sleep  1min  TC will wait until PM report is loaded.


Step1: Set ActZeroCounterSuppression To Non-PMQAP
    Log  \nStep1: Set ActZeroCounterSuppression To Non-PMQAP  console=true
    ${non_pmqap_list}  Create List  NR non-PMQAP sum Counters
    Change Specific Parameter For VCU  actZeroCounterSuppression  ${non_pmqap_list}  MRBTS-${VCU_MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1
    Sleep Until New Cycle  minutes_for_cycle=5min
    Sleep  1min  TC will wait until PM report is loaded.
    Open SSH Connection To VCU And Connect To Openshift
    ${oampm_pod_name}  Get Full Name For Pod  ${VCU_CRAN}  oampm
    ${oampm_container_name}  Get Full Name For Container  ${VCU_CRAN}  oampm
    Set Test Variable  ${OAMPM_POD_NAME}
    Set Test Variable  ${OAMPM_CONTAINER_NAME}

    [Teardown]  SSHLibrary.Close Connection


Step${index}: Check ${zero_counter_supp_value} Counters
    Log  \nStep${index}: Check ${zero_counter_supp_value} Counters  console=true
    ${last_pm_file_line}  Get Last File From PM Report Files From Vcu
    ${last_pm_file}  Remove String  ${last_pm_file_line}[-1]  '
    Open SHH Connection To VCU And Connect To Openshift
    ${copy_pm_file_command}  Catenate  kubectl cp
    ...  ${VCU_CRAN}/${OAMPM_POD_NAME}:/mnt/services/SS_OAM/PMSTAT/pm_report_files/${last_pm_file} /var/home/core/${last_pm_file}
    ...  -c ${OAMPM_CONTAINER_NAME}
    SSHLibrary.Write  ${copy_pm_file_command}
    SSHLibrary.Read Until Prompt
    Wait Until Keyword Succeeds  1min  10s  SSHLibrary.File Should Exist  /var/home/core/${last_pm_file}
    SSHLibrary.Get File  /var/home/core/${last_pm_file}  ${TEST_RESULTS_DIR}/${last_pm_file}
    ${pm_report_path_on_vm}  Set Variable  ${TEST_RESULTS_DIR}/PM_Report_WITH_${zero_counter_supp_value}_COUNTERS.xml
    Run  gzip -d -c ${TEST_RESULTS_DIR}/${last_pm_file} > ${pm_report_path_on_vm}
    Run  sed -i "s/></>\\n</g" ${pm_report_path_on_vm}
    ${counters_on_0}  Run  grep -E "<(M55)" ${pm_report_path_on_vm} | grep -iv "<MO dimension" | grep -e ">0<\\/M" | cut -d":" -f1 | sort | uniq -c
    ${counters_on_0}  Get Regexp Matches  ${counters_on_0}  M[0-9A-Z]+
    ${counters_on_0}  Remove Duplicates  ${counters_on_0}
    Check Counters In PM Report  zero_counter_supp_value=${zero_counter_supp_value}  counters_on_0=${counters_on_0}
    ...  report_name=PM_Report_WITH_${zero_counter_supp_value}_COUNTERS

    [Teardown]  Run Keywords  SSHLibrary.Execute command  rm /var/home/core/${last_pm_file}  AND  SSHLibrary.Close Connection
    ...  AND  Run  rm ${TEST_RESULTS_DIR}/${last_pm_file}


Step3: Set ActZeroCounterSuppression To PMQAP
    Log  \nStep3: Set ActZeroCounterSuppression To PMQAP  console=true
    ${pmqap_list}  Create List  NR PMQAP sum Counters
    Change Specific Parameter For VCU  actZeroCounterSuppression  ${pmqap_list}  MRBTS-${VCU_MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1
    Sleep Until New Cycle  minutes_for_cycle=5min
    Sleep  1min  TC will wait until PM report is loaded.


Step5: Set ActZeroCounterSuppression To Non-PMQAP And PMQAP
    Log  \nStep5: Set ActZeroCounterSuppression To Non-PMQAP And PMQAP  console=true
    ${zero_counters_list}  Create List  NR PMQAP sum Counters  NR non-PMQAP sum Counters
    Change Specific Parameter For VCU  actZeroCounterSuppression  ${zero_counters_list}  MRBTS-${VCU_MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1
    Sleep Until New Cycle  minutes_for_cycle=5min
    Sleep  1min  TC will wait until PM report is loaded.


Step6: Last Check For Non-PMQAP And PMQAP Counters
    Log  \nStep6: Last Check For Non-PMQAP And PMQAP Counters  console=true
    ${last_pm_file_line}  Get Last File From PM Report Files From Vcu
    ${last_pm_file}  Remove String  ${last_pm_file_line}[-1]  '
    Open SHH Connection To VCU And Connect To Openshift
    ${copy_pm_file_command}  Catenate  kubectl cp
    ...  ${VCU_CRAN}/${OAMPM_POD_NAME}:/mnt/services/SS_OAM/PMSTAT/pm_report_files/${last_pm_file} /var/home/core/${last_pm_file}
    ...  -c ${OAMPM_CONTAINER_NAME}
    SSHLibrary.Write  ${copy_pm_file_command}
    SSHLibrary.Read Until Prompt
    Wait Until Keyword Succeeds  1min  10s  SSHLibrary.File Should Exist  /var/home/core/${last_pm_file}
    SSHLibrary.Get File  /var/home/core/${last_pm_file}  ${TEST_RESULTS_DIR}/${last_pm_file}
    ${pm_report_path_on_vm}  Set Variable  ${TEST_RESULTS_DIR}/PM_Report_WITH_NON_PMQAP_AND_PMQAP_COUNTERS.xml
    Run  gzip -d -c ${TEST_RESULTS_DIR}/${last_pm_file} > ${pm_report_path_on_vm}
    Run  sed -i "s/></>\\n</g" ${pm_report_path_on_vm}

    ${counters_on_0}  Run  grep -E "<(M55)" ${pm_report_path_on_vm} | grep -iv "<MO dimension" | grep -e ">0<\\/M" | cut -d":" -f1 | sort | uniq -c
    ${counters_on_0}  Get Regexp Matches  ${counters_on_0}  M[0-9A-Z]+
    ${counters_on_0}  Remove Duplicates  ${counters_on_0}
    Check Counters In PM Report  zero_counter_supp_value=NON_PMQAP  counters_on_0=${counters_on_0}
    ...  report_name=PM_Report_WITH_NON_PMQAP_AND_PMQAP_COUNTERS
    Check Counters In PM Report  zero_counter_supp_value=PMQAP  counters_on_0=${counters_on_0}
    ...  report_name=PM_Report_WITH_NON_PMQAP_AND_PMQAP_COUNTERS

    [Teardown]  Run Keywords  SSHLibrary.Execute command  rm /var/home/core/${last_pm_file}  AND  SSHLibrary.Close Connection
    ...  AND  Run  rm ${TEST_RESULTS_DIR}/${last_pm_file}


Change ActZeroCounterSuppression To None If Needed
    ${zero_counter}  VCU Get Parameter Value  actZeroCounterSuppression  MRBTS-${VCU_MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1
    ${zero_counter_length}  Get Length  ${zero_counter}
    ${zero_counter_is_none}  Run Keyword And Return Status  Should Be True  ${zero_counter_length}==1 and '${zero_counter}[0]'=='None'
    IF  not ${zero_counter_is_none}
        ${none_list}  Create List  None
        Change Specific Parameter For VCU  actZeroCounterSuppression  ${none_list}  MRBTS-${VCU_MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1
    END


TC Setup
    Set Test Variable  ${TEST_VERDICT}  PASS
    ${FAIL_MESSAGES}  Create List
    Set Test Variable  ${FAIL_MESSAGES}
    Common VCU Setup
    Modify Resource Search Order  PM__vCU__Sum_NR_Counters_Suppression


TC Teardown
    Change ActZeroCounterSuppression To None If Needed
    IF  '${TEST_VERDICT}'=='FAIL'
        FOR  ${msg}  IN  @{FAIL_MESSAGES}
            Fail  ${msg}
        END
        Set Test Variable  ${TEST_STATUS}  FAIL
    END
    Common VCU Teardown