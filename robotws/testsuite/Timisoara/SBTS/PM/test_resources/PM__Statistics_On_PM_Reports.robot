*** Settings ***
Documentation
...  TC waits for at least one complete PM report to save 4 statistics in pm_reports_statistics.json file:
...    - number of counters per file
...    - how many counters per file are with value 0
...    - how many different measurements are per file
...    - number of objects per file.

Resource  ../../common_resources/ca_PM_general.robot


*** Keywords ***
TC__PM__Statistics_On_PM_Reports
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28148
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 30.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28148 - Initial TC creation
    ...  - 13.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30519 - Get SCF file with auto configured parameters

    Set Tags  CA-PM  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf  PHASE-CRT

    Step0: TC Preconditions
    Step1: Set Statistics From PM Reports
    Step2: Write Statistics In Json File


Step0: TC Preconditions
    coam.Get Current Scf File  ${BTS_FILES}  scf.xml  with_auto_configured_parameters=${TRUE}
    Setup Pm  scf_path=${BTS_FILES}/scf.xml
    ${reporting_interval_sec}  Get Reporting Interval
    ${reporting_interval_min}  Evaluate  int(${reporting_interval_sec}/60)

    ${ls_output}  SSHLibrary.Execute Command  ls -l /rom/uri/PERFMON_FILES
    ${pm_gz_files}  Get Regexp Matches  ${ls_output}  PM.*\.xml\.gz
    ${list_is_empty}  Run Keyword And Return Status  Should Be Empty  ${pm_gz_files}
    Return From Keyword If  not ${list_is_empty}
    Sleep Until New Cycle  minutes_for_cycle=${reporting_interval_min}
    Log  Sleep for ${reporting_interval_min} minutes until new entire ${reporting_interval_min} min cycle.  console=true
    Sleep  ${reporting_interval_min}min


Step1: Set Statistics From PM Reports
    Log  \nStep1: Set Statistics From PM Reports  console=true
    ${ls_output}  SSHLibrary.Execute Command  ls -l /rom/uri/PERFMON_FILES
    ${pm_gz_files}  Get Regexp Matches  ${ls_output}  PM.*\.xml\.gz

    ${PM_REPORTS_STATISTICS}  Create Dictionary
    Set Test Variable  ${PM_REPORTS_STATISTICS}
    FOR  ${gz_file}  IN  @{pm_gz_files}
        ${xml_file}  Fetch From Left  ${gz_file}  .gz
        ${path}  Set Variable  /rom/uri/PERFMON_FILES

        SSHLibrary.Execute Command  gzip -d -c ${path}/${gz_file} > ${path}/test_${xml_file}
        SSHLibrary.Execute Command  sed -i "s/></>\\n</g" ${path}/test_${xml_file}

        ${counters_number_command}  Set Variable  grep "<M" ${path}/test_${xml_file} | grep -iv "<MO dimension" | cut -d":" -f1 | uniq -c | wc -l
        ${counters_set_on_0_command}  Catenate  grep "<M" ${path}/test_${xml_file} | grep -iv "<MO dimension" | grep -e ">0<\\/M" | cut -d":" -f1 |
        ...  sort | uniq -c | wc -l
        ${meas_number_command}  Catenate  grep "<M" ${path}/test_${xml_file} | grep -iv "<MO dimension" | cut -d">" -f1 | sed -e "s/[0-9]*$//g" |
        ...  sort -u | cut -d":" -f1 | uniq -c | wc -l

        ${counters_number}  SSHLibrary.Execute Command  ${counters_number_command}
        ${counters_set_on_0}  SSHLibrary.Execute Command  ${counters_set_on_0_command}
        ${meas_number}  SSHLibrary.Execute Command  ${meas_number_command}
        ${dn_objects_output}  SSHLibrary.Execute Command  grep "<DN>" ${path}/test_${xml_file} | sort -u | sed -e "s/-[0-9]*<\\/DN>//g" | uniq -c
        ${dn_objects_output}  Split To Lines  ${dn_objects_output}
        ${dn_objects}  Get Objects Number And Path  ${dn_objects_output}

        ${statistics_dict}  Create Dictionary  number_of_counters=${counters_number}  number_of_counters_set_on_0=${counters_set_on_0}
        ...  number_of_measurements=${meas_number}  dn_objects=${dn_objects}
        Set To Dictionary  ${PM_REPORTS_STATISTICS}  ${xml_file}=${statistics_dict}
    END


Step2: Write Statistics In Json File
    Log  \nStep2: Write Statistics In Json File  console=true
    ${json_string}  Evaluate  json.dumps(${PM_REPORTS_STATISTICS}, indent=4)  json
    ${path_to_json}  Remove String  ${BTS_FILES}  /BTSFiles
    Create File  ${path_to_json}/pm_reports_statistics.json  ${json_string}


Get Objects Number And Path
    [Arguments]  ${dn_objects_output}

    ${dn_objects_path}  Create List
    FOR  ${obj_line}  IN  @{dn_objects_output}
        ${obj_path}  Get Regexp Matches  ${obj_line}  [0-9]* <DN>.*
        Append To List  ${dn_objects_path}  ${obj_path}[0]
    END

    [Return]  ${dn_objects_path}


TC Setup
    Common Test Setup
    SSHLibrary.Open Connection  ${OAM_BTS_IP}  prompt=:~ >  alias=pm_statistics
    SSHLibrary.Login  ${SMOD1}[USERNAME]  ${SMOD1}[PASSWORD]


TC Teardown
    SSHLibrary.Execute Command  rm /rom/uri/PERFMON_FILES/test_*
    SSHLibrary.Close Connection
    Common Test Teardown