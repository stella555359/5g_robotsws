*** Settings ***
Documentation  This suite contains PM__vCU__OAMNE3SADAPT_service_shall_be_restored_automatically_after_process_failure

Resource  ../test_resources/PM__vCU__OAMNE3SADAPT_service_shall_be_restored_automatically_after_process_failure.robot


*** Test Cases ***
PM__vCU__OAMNE3SADAPT_service_shall_be_restored_automatically_after_process_failure
    [Setup]  TC Setup
    TC__PM__vCU__OAMNE3SADAPT_service_shall_be_restored_automatically_after_process_failure
    [Teardown]  TC Teardown
