*** Settings ***
Documentation  This suite contains KPI__SBTS_SOAM_rollback_to_SBTS_SOAM TC

Resource  ../test_resources/KPI__SBTS_SOAM_rollback_to_SBTS_SOAM.robot


*** Test Cases ***
KPI__SBTS_SOAM_rollback_to_SBTS_SOAM
    [Setup]  TC Setup
    TC__KPI__SBTS_SOAM_rollback_to_SBTS_SOAM
    [Teardown]  TC Teardown
