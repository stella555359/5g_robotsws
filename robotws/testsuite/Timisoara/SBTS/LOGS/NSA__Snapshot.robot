*** Settings ***
Resource    ../resources/nsa_snapshot_sender.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    taf/rfrl/scrambling_logs_collector/Keywords.robot
Library     taf.gnb.oam.coam.admin  WITH NAME  coam_admin

*** Variables ***
${SNAPSHOT_TIMEOUT}      600                      #timeout for collect snapshot via Admin (in sec)

*** Keywords ***
TC__NSA__Snapshot
    [Documentation]
    ...  ******************
    ...  Owner: Marcin Berkowski
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2022-03-09 - https://jira3.ext.net.nokia.com/browse/TAT-22770 - Initial Creation
    ...  - 2022-05-11 - https://jiradc.ext.net.nokia.com/browse/TAT-23101 - Update resource file for TC NSA__Snapshot (scrambling snapshot sender)
    ...  - 2022-06-27 - https://jiradc.ext.net.nokia.com/browse/TAT-23349 - Update resource file for TC NSA__Snapshot (scrambling snapshot sender)
    ...                                                                     and tag SRAN to PMLOGS
    ...  - 2022-07-19 - https://jiradc.ext.net.nokia.com/browse/TAT-23414 - KW(placeholder) Common step trigger for
    ...                 checking sleeping cells added in TC Teardown due to BIT CS4.3 Enable Sleeping Cell
    ...  - 2023-12-04 - https://jiradc.ext.net.nokia.com/browse/TAT-26533 - Change on RFRL solution
    ...
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  Purpose of this test case is to collect snapshot to NSA scrambling purpose and send it to proper place on VM.
    ...  *******************

    Run keyword and ignore error     Collect and send logs for scrambling verification   team_name=PZ3WRO5

TC Setup
    coam_admin.Setup Admin    admin_api_log_dir=/home/ute/test_results    update_interval=1000

TC Teardown
    Run Keywords
    ...    coam_admin.Teardown Admin    alias=default
    ...    AND    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration

