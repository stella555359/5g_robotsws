*** Settings ***
Documentation
    ...  This TC is checking if PM reports are generated according to reportingIntervalPm
    ...  parameter value.
    ...  This parameter is set to 5min, 15min, 30min and 60min.
    ...  For each update, TC is waiting a new entire time interval according to updated value
    ...  and for each case, only one PM report should be generated on oampm pod from vDU
    ...  in this location: /mnt/services/SS_OAM/PMSTAT/pm_report_files.
    ...  In the end, reportingIntervalPm will remain set to 60min.

Resource  ../../common_resources/vdu_frame.robot
Resource  ../resources/PM_general.robot


*** Keywords ***
TC__PM__vDU__Changing_Time_Interval_For_Collecting_PM_Counters
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26697
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  10.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26697 - Initial TAT creation
    ...  24.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29610 - Refactor pod name construction
    ...  ******************

    Set Tags  CA-PM  OWNER-adrian.rosa@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com
    ...  MAINTAINER-andrada-lavinia.baleti@nokia.com  GROUP_IN_CHARGE-TIM_1_Vrf   PHASE-CRT
    ...  FEATURE-CB009746

    Step1: Change Reporting Interval PM To 5min And Check PM Report
    Step2: Change Reporting Interval PM To 15min And Check PM Report
    Step3: Change Reporting Interval PM To 30min And Check PM Report
    Step4: Change Reporting Interval PM To 60min And Check PM Report


Step${index}: Change Reporting Interval PM To ${interval} And Check PM Report
    Log  \nStep${index}: Change Reporting Interval PM To ${interval} And Check PM Report  console=true
    ${rep_interval_value}  VDU Get Parameter Value  reportingIntervalPm  MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
    Run Keyword If  '${rep_interval_value}'!='${interval}'
    ...  Change specific parameter for vDU  reportingIntervalPm  ${interval}  MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
    Sleep Until New Cycle  ${interval}
    Sleep  1min  TC will wait until PM report is loaded.

    Open SSH Connection To VDU And Connect To Openshift
    ${oampm_pod_name}  Get Full Name For Pod  ${VDU_CRAN}  oampm
    ${oampm_container_name}  Get Full Name For Container  ${VDU_CRAN}  oampm
    ${get_pm_reports_comm}  Catenate  oc exec -it ${oampm_pod_name} -n ${VDU_CRAN} -c ${oampm_container_name}
    ...  -- ls -la /mnt/services/SS_OAM/PMSTAT/pm_report_files | tail -10 | sort -k6,6 -k7,7 -k8,8
    SSHLibrary.Write  ${get_pm_reports_comm}
    ${pm_reports}  SSHLibrary.Read Until Prompt
    ${lines}  Get Lines Containing String  ${pm_reports}  .xml.gz
    ${lines}  Split To Lines  ${lines}
    ${last_pm_report_line}  Split String  ${lines}[-1]  ${SPACE}
    SSHLibrary.Close Connection

    Sleep Until New Cycle  ${interval}
    Sleep  1min  TC will wait until PM report is loaded.

    Open SSH Connection To VDU And Connect To Openshift
    SSHLibrary.Write  ${get_pm_reports_comm}
    ${pm_reports_after_modification}  SSHLibrary.Read Until Prompt
    ${lines_after_modification}  Get Lines Containing String  ${pm_reports_after_modification}  .xml.gz
    ${lines_after_modification}  Split To Lines  ${lines_after_modification}
    ${last_pm_report_line_after_modification}  Split String  ${lines_after_modification}[-1]  ${SPACE}
    ${next_to_last_pm_report_line_after_modification}  Split String  ${lines_after_modification}[-2]  ${SPACE}
    Should Not Be Equal As Strings  ${last_pm_report_line_after_modification}[-1]  ${last_pm_report_line}[-1]
    ...  There is no new PM report generated after ${interval} time interval.
    Should Be Equal As Strings  ${next_to_last_pm_report_line_after_modification}[-1]  ${last_pm_report_line}[-1]
    ...  There are more than one PM reports generated after ${interval} time interval.

    [Teardown]  Run keywords  SSHLibrary.Close Connection  AND  Run Keyword And Ignore Error  vdu.Disconnect
    ...  AND  Connect To VDU  host=${VDU_OAM_IP}


TC Setup
    Common VDU Setup
    Modify Resource Search Order  PM__vDU__Changing_Time_Interval_For_Collecting_PM_Counters


TC Teardown
    Set Test Variable  ${COLLECT_SNAPSHOT}  always
    Common VDU Teardown
