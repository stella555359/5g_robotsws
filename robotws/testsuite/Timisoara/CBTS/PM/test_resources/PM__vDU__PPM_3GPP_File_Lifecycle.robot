*** Settings ***
Documentation
...  This TC is activating actPartialPmReportFile parameter and sets activeBulkPmReportingFormat to 3GPP for PPM files to be reported in
...  PMSTAT/ppm_3GPP location on Vdu. A new PPM file must be reported every minute. After an entire reporting interval, a PM report is deleted
...  and a new one is created in the same PMSTAT/ppm_3GPP location.
...  Once PM report is deleted, it is checked to be sent to NetAct using ne3sadapt logs.

Resource  ../../common_resources/vdu_frame.robot
Resource  ../resources/PM_general.robot


*** Keywords ***
TC__PM__vDU__PPM_3GPP_File_Lifecycle
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-30466
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  03.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30466 - Initial TAT creation

    Set Tags  CA-PM  OWNER-mihai-adrian.pirjol@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com  GROUP_IN_CHARGE-TIM_1_Vrf
    ...  FEATURE-CB013879

    Step0: TC Preconditions
    Step1: Check PPM File Is Generated Every 1 Minute
    Step2: Check PM Notification Sent To NetAct


Step0: TC Preconditions
    Log  \nStep0: TC Preconditions  console=true

    ${rep_interval_value}  VDU Get Parameter Value  reportingIntervalPm  MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
    IF  "${rep_interval_value}"!="5min"
        Change specific parameter for vDU  reportingIntervalPm  5min  MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
        Sleep Until New Cycle  5min
    END
    Change Specific Parameter For VDU  actPartialPmReportFile  true  MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    Change specific parameter for vDU  activeBulkPmReportingFormat  3GPP  MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1


Step1: Check PPM File Is Generated Every 1 Minute
    Log  \nStep1: Check PPM File Is Generated Every 1 Minute  console=true

    Sleep Until New Cycle  minutes_for_cycle=5min
    Wait For New 1 Minute Interval
    Sleep  40s  TC waits for new 3GPP PPM file to be generated.

    ${path_to_ppm_3gpp_files}  Set Variable  /mnt/services/SS_OAM/PMSTAT/ppm_3GPP/
    ${last_ppm_report_from_previous_interval_to_check}  ${current_ppm_file_line}  Get 3GPP PPM Files Name From Vdu Or Vcu  cbts_instance=VDU
    ...  ppm_files_location=${path_to_ppm_3gpp_files}
    ${current_ppm_file}  Set Variable  ${current_ppm_file_line}[-1]

    FOR  ${index}  IN RANGE  1  4
        Wait For New 1 Minute Interval
        Sleep  40s  TC waits for new 3GPP PPM file to be generated.
        ${last_ppm_report_from_previous_interval}  ${new_ppm_file_line}  Get 3GPP PPM Files Name From Vdu Or Vcu  cbts_instance=VDU
        ...  ppm_files_location=${path_to_ppm_3gpp_files}
        Should Be Equal As Strings  ${new_ppm_file_line}[-1]  ${current_ppm_file}
        ...  There is no new 3GPP PPM file generated as expected after ${index} minutes from current interval.
        Should Be Equal As Strings  ${last_ppm_report_from_previous_interval}  ${last_ppm_report_from_previous_interval_to_check}
        ...  Last PPM report from previous interval has changed before 5 min interval.
        ${current_ppm_file}  Set Variable  ${new_ppm_file_line}[-1]
    END
    Wait For New 1 Minute Interval
    Wait For New 1 Minute Interval
    Sleep  40s  TC waits for new 3GPP PPM file to be generated.
    ${last_ppm_report_from_previous_interval}  ${new_ppm_file_line}  Get 3GPP PPM Files Name From Vdu Or Vcu  cbts_instance=VDU
    ...  ppm_files_location=${path_to_ppm_3gpp_files}
    Should Not Be Equal As Strings  ${last_ppm_report_from_previous_interval}  ${last_ppm_report_from_previous_interval_to_check}
    ...  Last PPM report from previous interval is not changed after 5 min interval.
    ${PPM_REPORT_TO_BE_SENT_TO_NETACT}  Remove String  ${last_ppm_report_from_previous_interval_to_check}  ManagedElement=
    Set Test Variable  ${PPM_REPORT_TO_BE_SENT_TO_NETACT}


Step2: Check PM Notification Sent To NetAct
    Log  \nStep2: Check PM Notification Sent To NetAct  console=true

    Open SSH Connection To VDU And Connect To Openshift
    ${oamext_pod_name}  Get Full Name For Pod  ${VDU_CRAN}  oamext
    ${ne3sadapt_container_name}  Get Full Name For Container  ${VDU_CRAN}  ne3sadapt
    Set Client Configuration  prompt=[PM]Remove
    SSHLibrary.Write  oc logs -f -n ${VDU_CRAN} ${oamext_pod_name} -c ${ne3sadapt_container_name} | grep ${PPM_REPORT_TO_BE_SENT_TO_NETACT}
    Sleep  10s  Time for logs to be written in console output.
    ${ne3sadapt_logs}  SSHLibrary.Read Until Prompt
    Should Match Regexp  ${ne3sadapt_logs}  .*\\[PM\\]Send notification.*to COMA successfully.*
    ...  ${PPM_REPORT_TO_BE_SENT_TO_NETACT} was not sent to NetAct.
    Log  ${PPM_REPORT_TO_BE_SENT_TO_NETACT} is sent to NetAct.  console=true

    [Teardown]  SSHLibrary.Close Connection


TC Setup
    Common VDU Setup
    Modify Resource Search Order  PM__vDU__PPM_3GPP_File_Lifecycle


TC Teardown
    Common VDU Teardown
