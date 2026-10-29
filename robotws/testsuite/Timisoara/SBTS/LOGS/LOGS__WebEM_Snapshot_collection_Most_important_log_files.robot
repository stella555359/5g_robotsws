*** Settings ***
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Resource    ../resources/verdicts.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
${SNAPSHOT_TIMEOUT}      600                      #timeout for collect snapshot via Admin (in sec)

*** Keywords ***
TC__LOGS__WebEM_Snapshot_collection_Most_important_log_files
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25136
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Test case collect snapshot with coverage: most important logs fies
    ...
    ...  *******************
    ...  Test case flowchart https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/SBTS/
    ...                      LOGS__WebEM_Snapshot_collection_Most_important_log_files.png
    ...  *******************

    Set Tags    CA-LOGS   AUTHOR-dominika.palka@nokia.com    MAINTAINER-dominika.palka@nokia.com    GROUP_IN_CHARGE-WRO_6_Vrf
    ...         PHASE-CRT    SW-SBTS23R2    FEATURE-CB008325

    Step1: Collect Minor Snapshot

Step1: Collect Minor Snapshot
    [Documentation]
    ...  In this test step is collected snapshot with coverage: most important log fies

    Log    Step1: Collect Minor Snapshot    console=${True}
    @{time}=    Get Time    year month day hour min
    ${snapshot_status}    Run Keyword And Return Status
    ...    coam.Collect Snapshot    ${BTS Files}/snapshot_${time[0]}_${time[1]}_${time[2]}_${time[3]}_${time[4]}.zip
    ...    coverage=Minor  timeout=${SNAPSHOT_TIMEOUT}
    Run Keyword If    ${snapshot_status}
    ...    Log    Collecting snapshot via admin succeeded    console=${True}
    ...    ELSE
    ...    verdicts.Set Test Failed  TC failed - Collecting snapshot using admin has failed.  ${TRUE}
    Log    Checking if there are no unexpected alarms raised during Snapshot collection.  console=${True}
    pm_logs_general.Check Unexpected Active And Historical Alarms


TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown
