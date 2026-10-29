*** Settings ***
Documentation
...  This TC is changing actZeroCounterSuppression parameter and verifies PMQAP and Non-PMQAP counters in PM reports.
...  actZeroCounterSuppression is set to 'NR non-PMQAP sum Counters', 'NR PMQAP sum Counters' and both 'NR PMQAP sum Counters' and
...  'NR PMQAP sum Counters'.
...  For each case, PMQAP or Non-PMQAP counters (depending on actZeroCounterSuppression value) may be missing, but in case they are visible in PM
...  reports, their value must not be equal to 0.
...  In the end, actZeroCounterSuppression is set to None.

Resource  ../../common_resources/ca_PM_general.robot


*** Variables ***
${EXPECTED_COUNTERS_PATH}  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PM/counters/Sum_NR_Counters_Suppression


*** Keywords ***
TC__PM__Sum_NR_Counters_Suppression
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29347
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 06.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29347 - Initial TAT creation
    ...  - 30.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29654 - Fix actZeroCounterSuppression last update
    ...  - 19.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30356 - Add faults for watchdog
    ...  - 16.01.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30396 - Start TC when new PM reporting interval begin

    Set Tags  CA-PM  OWNER-mohamad.al_hamwi@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com  GROUP_IN_CHARGE-TIM_1_Vrf
    ...  CNI-137374  CNI-134957

    Step0: TC Precondition
    Step1: Set ActZeroCounterSuppression To Non-PMQAP
    Step2: Check NON_PMQAP Counters
    Step3: Set ActZeroCounterSuppression To PMQAP
    Step4: Check PMQAP Counters
    Step5: Set ActZeroCounterSuppression To Non-PMQAP And PMQAP
    Step6: Last Check For Non-PMQAP And PMQAP Counters


Step0: TC Precondition
    Change ActZeroCounterSuppression To None If Needed
    ${param_list}  Create List  reportingIntervalPm
    ${parameter}  Get Parameter By Distname  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMCADM-1  ${param_list}
    ${reporting_interval}  Set Variable  ${parameter}[0][parameters][reportingIntervalPm]
    SSHLibrary.Open Connection  ${OAM_BTS_IP}  prompt=:~ >  alias=pm_statistics
    SSHLibrary.Login  ${SMOD1}[USERNAME]  ${SMOD1}[PASSWORD]
    ${pm_gz_files}  SSHLibrary.List Files In Directory  /rom/uri/PERFMON_FILES  PM.*\.xml\.gz
    ${list_is_empty}  Run Keyword And Return Status  Should Be Empty  ${pm_gz_files}
    IF  ${list_is_empty}
        Sleep Until New Cycle  minutes_for_cycle=${reporting_interval}
        Sleep  1min  TC will wait until PM report is loaded.
    END
    Set Test Variable  ${REPORTING_INTERVAL}

    [Teardown]  SSHLibrary.Close Connection


Step1: Set ActZeroCounterSuppression To Non-PMQAP
    Log  \nStep1: Set ActZeroCounterSuppression To Non-PMQAP  console=true
    Sleep Until New Cycle  minutes_for_cycle=${REPORTING_INTERVAL}
    ${non_pmqap_list}  Create List  NR non-PMQAP sum Counters
    Set Parameter To New Value  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1  actZeroCounterSuppression  ${non_pmqap_list}
    Sleep Until New Cycle  minutes_for_cycle=${REPORTING_INTERVAL}
    Sleep  1min  TC will wait until PM report is loaded.


Step${index}: Check ${zero_counter_supp_value} Counters
    Log  \nStep${index}: Check ${zero_counter_supp_value} Counters  console=true
    SSHLibrary.Open Connection  ${OAM_BTS_IP}  prompt=:~ >  alias=pm_statistics
    SSHLibrary.Login  ${SMOD1}[USERNAME]  ${SMOD1}[PASSWORD]
    ${last_xml_file}  Extract Last Gz File From SBTS AND Get XML File Name
    ${last_xml_file}  Remove String  ${last_xml_file}  test_
    ${pm_report_path_on_vm}  Set Variable  ${BTS_FILES}/PM_Report_WITH_${zero_counter_supp_value}_COUNTERS.xml
    SSHLibrary.Get File  /rom/uri/PERFMON_FILES/test_${last_xml_file}  ${pm_report_path_on_vm}
    ${counters_on_0}  Run  grep -E "<(M55)" ${pm_report_path_on_vm} | grep -iv "<MO dimension" | grep -e ">0<\\/M" | cut -d":" -f1 | sort | uniq -c
    ${counters_on_0}  Get Regexp Matches  ${counters_on_0}  M[0-9A-Z]+
    ${counters_on_0}  Remove Duplicates  ${counters_on_0}
    Check Counters In PM Report  zero_counter_supp_value=${zero_counter_supp_value}  counters_on_0=${counters_on_0}
    ...  report_name=PM_Report_WITH_${zero_counter_supp_value}_COUNTERS

    [Teardown]  Run Keywords  SSHLibrary.Execute Command  rm /rom/uri/PERFMON_FILES/test_${last_xml_file}  AND  SSHLibrary.Close Connection


Step3: Set ActZeroCounterSuppression To PMQAP
    Log  \nStep3: Set ActZeroCounterSuppression To PMQAP  console=true
    ${pmqap_list}  Create List  NR PMQAP sum Counters
    Set Parameter To New Value  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1  actZeroCounterSuppression  ${pmqap_list}
    Sleep Until New Cycle  minutes_for_cycle=${REPORTING_INTERVAL}
    Sleep  1min  TC will wait until PM report is loaded.


Step5: Set ActZeroCounterSuppression To Non-PMQAP And PMQAP
    Log  \nStep5: Set ActZeroCounterSuppression To Non-PMQAP And PMQAP  console=true
    ${zero_counters_list}  Create List  NR PMQAP sum Counters  NR non-PMQAP sum Counters
    Set Parameter To New Value  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1  actZeroCounterSuppression  ${zero_counters_list}
    Sleep Until New Cycle  minutes_for_cycle=${REPORTING_INTERVAL}
    Sleep  1min  TC will wait until PM report is loaded.


Step6: Last Check For Non-PMQAP And PMQAP Counters
    Log  \nStep6: Last Check For Non-PMQAP And PMQAP Counters  console=true
    SSHLibrary.Open Connection  ${OAM_BTS_IP}  prompt=:~ >  alias=pm_statistics
    SSHLibrary.Login  ${SMOD1}[USERNAME]  ${SMOD1}[PASSWORD]
    ${last_xml_file}  Extract Last Gz File From SBTS AND Get XML File Name
    ${last_xml_file}  Remove String  ${last_xml_file}  test_
    ${pm_report_path_on_vm}  Set Variable  ${BTS_FILES}/PM_Report_WITH_NON_PMQAP_AND_PMQAP_COUNTERS.xml
    SSHLibrary.Get File  /rom/uri/PERFMON_FILES/test_${last_xml_file}  ${pm_report_path_on_vm}
    ${counters_on_0}  Run  grep -E "<(M55)" ${pm_report_path_on_vm} | grep -iv "<MO dimension" | grep -e ">0<\\/M" | cut -d":" -f1 | sort | uniq -c
    ${counters_on_0}  Get Regexp Matches  ${counters_on_0}  M[0-9A-Z]+
    ${counters_on_0}  Remove Duplicates  ${counters_on_0}
    Check Counters In PM Report  zero_counter_supp_value=NON_PMQAP  counters_on_0=${counters_on_0}
    ...  report_name=PM_Report_WITH_NON_PMQAP_AND_PMQAP_COUNTERS
    Check Counters In PM Report  zero_counter_supp_value=PMQAP  counters_on_0=${counters_on_0}
    ...  report_name=PM_Report_WITH_NON_PMQAP_AND_PMQAP_COUNTERS

    [Teardown]  Run Keywords  SSHLibrary.Execute Command  rm /rom/uri/PERFMON_FILES/test_${last_xml_file}  AND  SSHLibrary.Close Connection


Change ActZeroCounterSuppression To None If Needed
    ${param_list}  Create List  actZeroCounterSuppression
    ${parameter}  Get Parameter By Distname  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1  ${param_list}
    ${zero_counter}  Set Variable  ${parameter}[0][parameters][actZeroCounterSuppression]
    ${zero_counter_length}  Get Length  ${zero_counter}
    ${zero_counter_is_none}  Run Keyword And Return Status  Should Be True  ${zero_counter_length}==1 and '${zero_counter}[0]'=='None'
    IF  not ${zero_counter_is_none}
        ${none_list}  Create List  None
        Set Parameter To New Value  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1  actZeroCounterSuppression  ${none_list}
    END


Check Counters In PM Report
    [Arguments]  ${zero_counter_supp_value}  ${counters_on_0}  ${report_name}
    ${expected_counters}  OperatingSystem.Grep File  ${EXPECTED_COUNTERS_PATH}/${zero_counter_supp_value}_Counters.txt  M55
    ${expected_counters}  Split To Lines  ${expected_counters}

    ${counters_on_0_not_ok}  Evaluate  list(filter(lambda x: x in ${expected_counters}, ${counters_on_0}))
    ${length}  Get Length  ${counters_on_0_not_ok}
    IF  ${length}>0
        Log  Following ${zero_counter_supp_value} from ${report_name}.xml are equal to 0:\n${counters_on_0_not_ok}.  level=ERROR
        Set Test Failed  Following ${zero_counter_supp_value} from ${report_name}.xml are equal to 0:\n${counters_on_0_not_ok}.
    END


TC Setup
    Common Test Setup  tc_name=PM__Sum_NR_Counters_Suppression


TC Teardown
    Change ActZeroCounterSuppression To None If Needed
    Common Test Teardown