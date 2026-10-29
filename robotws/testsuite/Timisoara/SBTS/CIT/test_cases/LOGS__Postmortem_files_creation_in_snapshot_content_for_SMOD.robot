*** Settings ***
Documentation  This suite contains LOGS__Postmortem_files_creation_in_snapshot_content_for_SMOD TC

Resource  ../test_resources/LOGS__Postmortem_files_creation_in_snapshot_content_for_SMOD.robot


*** Test Cases ***
LOGS__Postmortem_files_creation_in_snapshot_content_for_SMOD
    [Setup]  TC Setup
    TC__LOGS__Postmortem_files_creation_in_snapshot_content_for_SMOD
    [Teardown]  TC Teardown
