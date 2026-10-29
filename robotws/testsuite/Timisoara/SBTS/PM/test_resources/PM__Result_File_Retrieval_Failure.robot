*** Settings ***
Documentation
...  This TC is checking PM reports messages from syslog.
...  After 15 min PM reporting interval, last PM report is added in TC list.
...  O&M connection is dropped by creating a new IPIF interface with dummy M-plane address and mapping it to MPLANENW object.
...  After another 15 min cycle, last PM report from SBTS is saved in TC variable.
...  O&M connection is restored and after 15 min cycle, a new PM report is added.
...  All three PM reports must be detected as successfully transfered to NetAct by checking expected syslog entries.
...  TC is checking if last 2 PM Reports are reported after O&M reconnection, not earlier.

Resource  ../../common_resources/ca_PM_general.robot


*** Keywords ***
TC__PM__Result_File_Retrieval_Failure
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28743
    ...
    ...  *******************
    ...  History of changes
    ...  - 11.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28743 - Initial TAT creation
    ...  - 24.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29446 - Delete Netact Setup and Teardown
    ...  - 17.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30209 - Get unarchived syslog file dynamically
    ...  - 27.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30241 - Get time right before restoring M-plane

    Set Tags  CA-PM  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com  GROUP_IN_CHARGE-TIM_1_Vrf  FEATURE-LTE877

    Step0: TC Preconditions
    Step1: Add PM File Which Is Reported On Time In Netact
    Step2: Drop OAM Connection
    Step3: Add PM File Which Is Reported Later In Netact
    Step4: Restore OAM Connection
    Step5: Add PM File Which Is Reported On Time In Netact


Step0: TC Preconditions
    Set Parameter To New Value  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMCADM-1  reportingIntervalPm  15min
    Sleep Until New Cycle  minutes_for_cycle=15min
    ${time_after_first_pm_interval}  Get Current Date  UTC  result_format=%Y-%m-%d %H:%M:%S.%f
    Set Test Variable  ${TIME_AFTER_FIRST_PM_INTERVAL}
    Sleep  1min  TC waits until counters are fully loaded.
    ${PM_TO_BE_REPORTED_ON_TIME}  Create List
    Set Test Variable  ${PM_TO_BE_REPORTED_ON_TIME}


Step${index}: Add PM File Which Is Reported On Time In Netact
    Log  \nStep${index}: Check PM File To Be Reported In Netact  console=true
    SSHLibrary.Open Connection  ${OAM_BTS_IP}  prompt=:~ >  alias=pm_statistics
    SSHLibrary.Login  ${SMOD1}[USERNAME]  ${SMOD1}[PASSWORD]
    ${pm_gz_files}  SSHLibrary.List Files In Directory  /rom/uri/PERFMON_FILES  PM.*\.xml\.gz
    Append To List  ${PM_TO_BE_REPORTED_ON_TIME}  ${pm_gz_files}[-1]

    [Teardown]  SSHLibrary.Close Connection


Step2: Drop OAM Connection
    Log  \nStep2: Drop OAM Connection  console=true
    Set IPIF interface
    Create IPADDRESSV4-2
    Change Mplane IP
    Sleep Until New Cycle  minutes_for_cycle=15min
    Sleep  1min  TC waits until counters are fully loaded.


Step3: Add PM File Which Is Reported Later In Netact
    Log  \nStep3: Check PM File To Be Not Reported In NetAct  console=true
    SSHLibrary.Open Connection  ${OAM_BTS_IP}  prompt=:~ >  alias=pm_statistics
    SSHLibrary.Login  ${SMOD1}[USERNAME]  ${SMOD1}[PASSWORD]
    ${pm_gz_files}  SSHLibrary.List Files In Directory  /rom/uri/PERFMON_FILES  PM.*\.xml\.gz
    Set Test Variable  ${PM_TO_BE_REPORTED_LATER}  ${pm_gz_files}[-1]

    Sleep Until New Cycle  minutes_for_cycle=15min
    Sleep  1min  TC waits until counters are fully loaded.

    [Teardown]  SSHLibrary.Close Connection


Step4: Restore OAM Connection
    Log  \nStep4: Restore OAM Connection  console=true
    ${time_right_before_restoring_mplane}  Get Current Date  UTC  result_format=%Y-%m-%d %H:%M:%S.%f
    Set Test Variable  ${TIME_RIGHT_BEFORE_RESTORING_MPLANE}
    Restore Mplane
    Remove IPADDRESSV4-2


Check PM Reports In Syslog
    Log  \nCheck PM Reports In Syslog  console=true
    Unarchive Syslogs From UDPLogs Directory
    ${syslog_files}  OperatingSystem.List Directory  ${UDP_LOGS}/Unarchived
    ${syslog_pc_file}  Get Matches  ${syslog_files}  *_PC_*
    ${syslog_bts_file}  Get Matches  ${syslog_files}  *_BTS_*

    ${syslog_targeted}  Combine Lists  ${syslog_pc_file}  ${syslog_bts_file}

    ${syslog_file_path}  Set Variable  ${UDP_LOGS}/Unarchived/${syslog_targeted}[0]
    Check PM Report In Syslog  ${PM_TO_BE_REPORTED_ON_TIME}[0]  ${syslog_file_path}  ${TIME_AFTER_FIRST_PM_INTERVAL}
    Check PM Report In Syslog  ${PM_TO_BE_REPORTED_LATER}  ${syslog_file_path}  ${TIME_RIGHT_BEFORE_RESTORING_MPLANE}
    Check PM Report In Syslog  ${PM_TO_BE_REPORTED_ON_TIME}[1]  ${syslog_file_path}  ${TIME_RIGHT_BEFORE_RESTORING_MPLANE}

    [Teardown]  Delete Unarchived Syslogs From UDPLogs Directory


Recovery Action
    ${bts_obj}  Get Parameters For All  BTS
    ${mplane_ip_value}  Set Variable  ${bts_obj}[0][btsMplaneIp4V]
    IF  '${mplane_ip_value}'!='${MPLANE_IP}'
        Restore Mplane
        Remove IPADDRESSV4-2
    END


TC Setup
    Common Test Setup


TC Teardown
    Run Keyword If Test Failed  Recovery Action
    Common Test Teardown
    Check PM Reports In Syslog
