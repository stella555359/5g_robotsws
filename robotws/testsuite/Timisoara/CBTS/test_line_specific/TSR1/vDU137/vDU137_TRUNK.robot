*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SRAN  CLOUD_5GC_dRNIC_1vDU34_O_AHBCC  STATE_COMMISSIONED
Library           XML  use_lxml=True
Documentation  This suite contains CloudBTS TC

Resource    ../../../PM/test_resources/PM__vDU__OAMNE3SADAPT_service_shall_be_restored_automatically_after_process_failure.robot
Resource    ../../../PM/test_resources/PM__vDU__Changing_Time_Interval_For_Collecting_PM_Counters.robot


*** Test Cases ***


[1]PM__vDU__OAMNE3SADAPT_service_shall_be_restored_automatically_after_process_failure
    [Tags]     QC_176241
    [Timeout]    14400
    [Setup]    PM__vDU__OAMNE3SADAPT_service_shall_be_restored_automatically_after_process_failure.TC Setup
    TC__PM__vDU__OAMNE3SADAPT_service_shall_be_restored_automatically_after_process_failure
    [Teardown]    PM__vDU__OAMNE3SADAPT_service_shall_be_restored_automatically_after_process_failure.TC Teardown


[1]PM__vDU__Changing_Time_Interval_For_Collecting_PM_Counters
    [Tags]     QC_176231
    [Timeout]    14400
    [Setup]    PM__vDU__Changing_Time_Interval_For_Collecting_PM_Counters.TC Setup
    TC__PM__vDU__Changing_Time_Interval_For_Collecting_PM_Counters
    [Teardown]    PM__vDU__Changing_Time_Interval_For_Collecting_PM_Counters.TC Teardown


