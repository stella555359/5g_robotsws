*** Settings ***
Documentation
...  First, site reset is performed and TC waits until SBTS is reaching on air state.
...  In TC teardown, syslog files must contain NE3S interface specific message which implies that NE3S connection
...  was established after site reset.

Resource  ../../common_resources/ca_PM_general.robot


*** Variables ***
${RESTORE_TIMEOUT}  1200  # Time in seconds for SBTS to reach on air state


*** Keywords ***
TC__PM__NE3S_Interface_Setup_In_Startup
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28819
    ...
    ...  *******************
    ...  History of changes
    ...  - 24.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28819 - PM transfer from Oulu
    ...  - 06.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29348 - Remove NetAct web url verification
    ...  - 19.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30356 - Add faults for watchdog

    Set Tags  CA-PM  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf  FEATURE-LTE3346-D-l;LTE602-a;LTE877;RP002324-C

    Step1: Perform Site Reset


Step1: Perform Site Reset
    Log  \nStep1: Perform Site Reset  console=true
    coam.Reset Site  timeout=600
    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT}  15  Admin Check All Required State
    Log  SBTS is on air after site reset.  console=true


Check NE3S Interface Setup In Syslog
    Unarchive Syslogs From UDPLogs Directory
    ${message_pattern}  Catenate  SEPARATOR=  .INF\/Ne3sAdapter\/Manager,\\s+\\[nmsservicefacade::Ne3sadaptContextUpdater\\]
    ...  \\s+update\\s+Ne3sSession\\s+to\\s+OperationalState.+:\\s+\\d+\\s+proceduralState.+
    ${syslog_files}  OperatingSystem.List Directory  ${UDP_LOGS}/Unarchived
    FOR  ${file}  IN  @{syslog_files}
        ${pattern}  Grep File  ${UDP_LOGS}/Unarchived/${file}  ${message_pattern}  regexp=${TRUE}
        ${pattern_found}  Run Keyword And Return Status  Should Not Be Empty  ${pattern}
        IF  ${pattern_found}
            Log  NE3S connection was established after site reset. Message found in syslog ${file} file.  console=true
            RETURN
        END
    END

    Fail  NE3S connection was not established after site reset. Message not found in syslog.

    [Teardown]  Delete Unarchived Syslogs From UDPLogs Directory


TC Setup
    Common Test Setup  tc_name=PM__NE3S_Interface_Setup_In_Startup


TC Teardown
    Common Test Teardown
    Check NE3S Interface Setup In Syslog
