*** Settings ***
Documentation
...  This test case is monitoring PPM OMeS File Lifecycle.
...  Parameters setting:
...    -actPartialPmReportFile = true
...    -activeBulkPmReportingFormat = OMeS
...    -reportinginterval = 5 min
...  Every minute, the OAM (oampm) component creates a new, updated OMeS PPM file.
...  This file contains cumulative data from the beginning of the current reporting interval up to the current minute:
...  The created PPM file is stored in persistent memory at the following path for cloud environments: /mnt/services/SS_OAM/PMSTAT/ppm_omes/
...  1) Every minute, OAM (oampm) creates/updates an OMeS PPM file containing cumulative data for the current reporting interval.
...  2) At the end of a complete reporting interval (e.g. 10:00-10:05), the system generates the full PM report (A...xml.gz)
...     and ne3sadapt sends a successful notification to COMA/NetAct.
...  3) After ~5 minutes from successful notification, oampm deletes the obsolete PPM file for the completed interval.
...  The automation parses oampm and ne3sadapt logs to confirm creation and deletion

Resource  ../../common_resources/vcu_frame.robot
Resource  ../resources/PM_general.robot


*** Variables ***
${RE_PPM_CREATE_LINE}  PPM result file created: +\/mnt\/services\/SS_OAM\/PMSTAT\/ppm_omes\/PPM[^ ]+\.xml\.gz
${RE_PPM_DELETE_LINE}  Deleted file: +\/mnt\/services\/SS_OAM\/PMSTAT\/ppm_omes\/PPM[^ ]+\.xml\.gz
${RE_PPM_FILE_PARTS}  PPM([0-9]{8}\.[0-9]{4}[+][0-9]{4})-([0-9]{8}\.[0-9]{4}[+][0-9]{4})_(MRBTS-[0-9]+)\.xml\.gz


*** Keywords ***
TC__PM__vCU__PPM_OMeS_File_Lifecycle
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-30461
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  09.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30461 - TC creation

    Set Tags  CA-PM  OWNER-mihai-adrian.pirjol@nokia.com  AUTHOR-cristina.adam@nokia.com  GROUP_IN_CHARGE-TIM_1_Vrf  PHASE-CRT  FEATURE-CB013879-CR

    Step0: TC Preconditions
    Step1: Check New PPM File Is Created On Vcu
    Step2: Check New PPM File Is Notified On Vcu
    Step3: Check New PPM File Is Deleted On Vcu


Step0: TC Preconditions
    Log  \nStep0: TC Preconditions  console=true

    Change Specific Parameter For VCU  actPartialPmReportFile  true  MRBTS-${VCU_MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    Change Specific Parameter For VCU  activeBulkPmReportingFormat  OMeS  MRBTS-${VCU_MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
    Change Specific Parameter For VCU  reportingIntervalPm  5min  MRBTS-${VCU_MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
    Change Specific Parameter For VCU  miNrCellAvailability  5min  MRBTS-${VCU_MRBTS_ID}/NRBTS-${VCU_NRBTS_ID}/NRPMRNL-1


Step1: Check New PPM File Is Created On Vcu
    Log  \nStep1: Check New PPM File Is Created On Vcu  console=true

    Sleep Until New Cycle  5min
    Sleep  1min  TC will wait until PM report is loaded.
    ${ppm_file_from_line_vcu}  Get Last PPM PM File Line From Vcu
    ${ppm_file_from_vcu}  Set Variable  ${ppm_file_from_line_vcu}[-1]
    Open SHH Connection To VCU And Connect To Openshift
    ${oampm_pod}  Get Full Name For Pod  ${VCU_CRAN}  oampm
    Set Test Variable  ${OAMPM_POD}
    ${oampm_container}  Get Full Name For Container  ${VCU_CRAN}  oampm
    Set Test Variable  ${OAMPM_CONTAINER}
    ${oamext_pod}  Get Full Name For Pod  ${VCU_CRAN}  oamext
    Set Test Variable  ${OAMEXT_POD}
    ${ne3s_container}  Get Full Name For Container  ${VCU_CRAN}  ne3sadapt
    Set Test Variable  ${NE3S_CONTAINER}

    ${ppm_file_path}  ${ppm_start_time}  ${end}  ${bts}  Wait Until Keyword Succeeds  600  10
    ...  Extract Latest PPM Creation From OAMPM Logs  ${VCU_CRAN}  ${OAMPM_POD}  ${OAMPM_CONTAINER}  ${ppm_file_from_vcu}
    Set Test Variable  ${PPM_FILE_PATH}
    Set Test Variable  ${PPM_START_TIME}

    [Teardown]  SSHLibrary.Close Connection


Step2: Check New PPM File Is Notified On Vcu
    Log  \nStep2: Check New PPM File Is Notified On Vcu  console=true

    Sleep Until New Cycle  5min
    Sleep  1min  TC will wait until PM report is loaded.
    Open SHH Connection To VCU And Connect To Openshift
    ${ppm_a_file_path}  Wait Until Keyword Succeeds  600  10
    ...  Extract Full PPM Notification Matching Interval  ${VCU_CRAN}  ${OAMEXT_POD}  ${NE3S_CONTAINER}  ${PPM_START_TIME}
    Log  Full PM notification A-file path: ${ppm_a_file_path}  console=true

    [Teardown]  SSHLibrary.Close Connection


Step3: Check New PPM File Is Deleted On Vcu
    Log  \nStep3: Check New PPM File Is Deleted On Vcu  console=true

    Sleep Until New Cycle  5min
    Sleep  1min  TC will wait until PM report is loaded.
    Open SHH Connection To VCU And Connect To Openshift
    Wait Until Keyword Succeeds  600  10
    ...  Verify PPM Deletion For Same File  ${VCU_CRAN}  ${OAMPM_POD}  ${OAMPM_CONTAINER}  ${PPM_FILE_PATH}

    [Teardown]  SSHLibrary.Close Connection


Get Last PPM PM File Line From Vcu
    [Documentation]  This KW is opening ssh connection to Vcu and is returning the last PPM PM file line
    ...  from /mnt/services/SS_OAM/PMSTAT/ppm_omes location.

    Open SHH Connection To VCU And Connect To Openshift
    ${oampm_pod_name}  Get Full Name For Pod  ${VCU_CRAN}  oampm
    ${oampm_container_name}  Get Full Name For Container  ${VCU_CRAN}  oampm
    ${get_pm_reports_comm}  Catenate  oc exec -it ${oampm_pod_name} -n ${VCU_CRAN} -c ${oampm_container_name}
    ...  -- ls -l /mnt/services/SS_OAM/PMSTAT/ppm_omes | tail -10 | sort -k6,6 -k7,7 -k8,8
    SSHLibrary.Write  ${get_pm_reports_comm}
    Sleep  10s  Time for all PPM files to be logged.
    ${pm_file_lines}  SSHLibrary.Read Until Prompt
    ${pm_file_lines}  Get Lines Containing String  ${pm_file_lines}  .xml.gz
    ${pm_file_lines}  Split To Lines  ${pm_file_lines}
    ${last_pm_file_line}  Split String  ${pm_file_lines}[-1]  ${SPACE}

    RETURN  ${last_pm_file_line}
    [Teardown]  SSHLibrary.Close Connection


Extract Full PPM Notification Matching Interval
    [Documentation]  Finds A-file notification line in ne3sadapt logs and validates it matches interval & BTS.
    [Arguments]  ${cran}  ${oamext_pod}  ${ne3s_container}  ${start}

    ${logs}  Get Logs Since Minutes  ${cran}  ${oamext_pod}  ${ne3s_container}
    ${notification_line}  Catenate  SEPARATOR=${SPACE}  Send notification indicator with key: PM+[0-9a-z]+-[[0-9a-z]+-[0-9a-z]+-[0-9a-z]+-[0-9a-z]+,
    ...  path: ([^ ]*\/A[0-9]{8}\.[0-9]{4}[+][0-9]{4}[-][0-9]{8}\.[0-9]{4}[+][0-9]{4}_MRBTS-[0-9]+\.xml\.gz).*successfully
    ${a_paths}  Get Regexp Matches  ${logs}  ${notification_line}  1
    ${length}  Get Length  ${a_paths}
    IF  ${length} > 0
        Log  Message 'Send notification indicator with key:' found in PPM file![OK]  console=true
    ELSE
        Fail  Message 'Send notification indicator with key:' not found in PPM file![NOK]
    END
    ${a_path}  Set Variable  ${a_paths}[-1]
    ${end_time}  Add Time To Date  ${start}  10 min
    ${end_time}  Convert Date  ${end_time}  result_format=%Y%m%d.%H%M+0200
    Should Contain  ${a_path}  ${end_time}

    RETURN  ${a_path}


Verify PPM Deletion For Same File
    [Documentation]  Confirms deletion log contains the same PPM file as created earlier.
    [Arguments]  ${cran}  ${oampm_pod}  ${oampm_container}  ${ppm_path}

    ${logs}  Get Logs Since Minutes  ${cran}  ${oampm_pod}  ${oampm_container}
    ${deleted_match_files}  Get Regexp Matches  ${logs}  ${RE_PPM_DELETE_LINE}
    ${length}  Get Length  ${deleted_match_files}
    IF  ${length} > 0
        Log  'Deleted file' found in PPM file![OK]  console=true
    ELSE
        Fail  'Deleted file' not found in PPM file![NOK]
    END
    ${ppm_file}  Fetch From Right  ${ppm_path}  /
    ${end_list}  Get Regexp Matches  ${ppm_file}  ${RE_PPM_FILE_PARTS}  1
    ${end_time}  Add Time To Date  ${end_list}[0]  10 min
    ${end_time}  Convert Date  ${end_time}  result_format=%Y%m%d.%H%M+0200
    ${found}  Set Variable  ${FALSE}
    FOR  ${deleted_file}  IN  @{deleted_match_files}
        ${file_name}  Fetch From Right  ${deleted_file}  /
        ${status}  Run Keyword And Return Status  Should Contain  ${file_name}  ${end_time}
        IF  ${status}
            ${found}  Set Variable  ${TRUE}
            BREAK
        END
    END
    Should Be True  ${found}  msg=Expected deletion for ${ppm_path} but not found in logs.
    Log  Expected deletion for ${ppm_path} found in logs.[OK]  console=true


Restore Parameters Value If Needed
    ${reporting_format}  VCU Get Parameter Value  activeBulkPmReportingFormat  MRBTS-${VCU_MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
    IF  '${reporting_format}'!='3GPP_OMeS'
        Change Specific Parameter For VCU  activeBulkPmReportingFormat  3GPP_OMeS  MRBTS-${VCU_MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
    END


TC Setup
    Common VCU Setup
    Modify Resource Search Order  PM__vCU__PPM_OMeS_File_Lifecycle


TC Teardown
    Run Keyword If Test Failed  Restore Parameters Value If Needed
    Common VCU Teardown
