*** Settings ***
Documentation    Suite description
...    Responsible tester:  patryk.niewiejski@nokia.com

Resource    ../../Resources/Setup/setup_and_teardown.robot
Resource    ../../robotlte_legacy/tc_scenarios.robot

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition


*** Variables ***
${CUSTOM_SWITCH_PERFORM_SNAPSHOT}=            None      # possible settings : Failed, Always, None
${CUSTOM_SWITCH_PERFORM_HW_SETUP}=            False     # to disable hardware reconfiguration ( PDU and Optical part ) set value False
# ${ENABLE_TRUCK_ROLL_FLAG}    ${False}  # FOR hran_ta
${SKIP_TRUCK_ROLL}    ${True}  # FOR NEW FRAME
@{additional_common_fault_list}=
...  faultId=2403
...  faultId=6450
&{CUSTOM_ADDITIONAL_ALLOWED_FAULTS}=   common=@{additional_common_fault_list}


*** Test Cases ***
[1][DEV] Automated_SiSo_DEV_Dummy_TC
  [Setup]  Configuration Precondition  CN=REF_10_16_UTESRANSISO901_DEFAULT  N=1
  Execute Test In Loop  TC__DEV_Dummy_TC
  [Teardown]  Configuration Postcondition

*** Keywords ***
TC__DEV_Dummy_TC
    Set Tags     AUTHOR-patryk.niewiejski@nokia.com  MAINTAINER-patryk.niewiejski@nokia.com
    Common Test Setup
    Logging With Timestamp
    ...  message=TC__DEV_Dummy_TC for every node on list : @{CFG.active_bts_list} will be executed
    ...  style=ONGOING
    Wrapper For Dummy TC  10s
    [Teardown]    Common Test Teardown

Wrapper For Dummy TC
    [Arguments]  ${time_to_sleep}=60s
    Log To Console  Tu jestem! Teraz ide spac na ${time_to_sleep}
    Sleep  ${time_to_sleep}
    Log To Console  Pospane. Dzialam dalej...
