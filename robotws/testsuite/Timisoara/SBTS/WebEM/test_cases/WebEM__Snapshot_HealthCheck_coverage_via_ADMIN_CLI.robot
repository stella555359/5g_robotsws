*** Settings ***
Documentation  This suite contains WebEM__Snapshot_HealthCheck_coverage_via_ADMIN_CLI TC

Resource  ../test_resources/WebEM__Snapshot_HealthCheck_coverage_via_ADMIN_CLI.robot


*** Test Cases ***
WebEM__Snapshot_HealthCheck_coverage_via_ADMIN_CLI
    [Setup]  TC Setup
    TC__WebEM__Snapshot_HealthCheck_coverage_via_ADMIN_CLI
    [Teardown]  TC Teardown
