*** Settings ***

Documentation
...  author: patryk.niewiejski@nokia.com
...  maintainer: patryk.niewiejski@nokia.com

Resource    ../../Resources/Setup/setup_and_teardown.robot
Resource    ../../robotlte_legacy/tc_scenarios.robot
Resource    ../../TestCases/SWM/SiSo_SWM_RU_and_BTS_SW_activate_triggered_by_WebEM.robot
Resource    ../../TestCases/SWM/SiSo_SWM_BTS_SW_Rollback_Reject_triggered_by_WebEM.robot
Resource    ../../TestCases/SWM/SiSo_SWM_Simultaneous_RU_SW_Activate_triggered_by_WebEM.robot
Resource    ../../TestCases/SWM/SiSo_SWM_Sequential_RU_SW_Activate_triggered_by_WebEM.robot

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition


*** Variables ***
${CUSTOM_SWITCH_PERFORM_SNAPSHOT}=            None      # possible settings : Failed, Always, None
${CUSTOM_SWITCH_PERFORM_HW_SETUP}=            False     # to disable hardware reconfiguration ( PDU and Optical part ) set value False
${ENABLE_TRUCK_ROLL_FLAG}    ${False}
${SKIP_TRUCK_ROLL}    ${False}
@{additional_common_fault_list}=
...  faultId=2403
...  faultId=6450
&{CUSTOM_ADDITIONAL_ALLOWED_FAULTS}=   common=@{additional_common_fault_list}


*** Test Cases ***
[1][1.0] Automated_SiSo_SWM_RU_and_BTS_SW_activate_triggered_by_WebEM
  [Setup]  Run Keywords
  ...  Configuration Precondition  CN=REF_10_16_UTESRANSISO901_DEFAULT  N=1
  ...  AND  Set Test Variable  @{TESTING_RMOD_SN}  BL2221N4069
  Execute Test In Loop  TC__SiSo_SWM_RU_and_BTS_SW_activate_triggered_by_WebEM
  [Teardown]  Configuration Postcondition

[1][1.0] Automated_SiSo_SWM_BTS_SW_Rollback_Reject_triggered_by_WebEM
  [Setup]  Configuration Precondition  CN=REF_10_16_UTESRANSISO901_DEFAULT  N=1
  Execute Test In Loop  TC__SiSo_SWM_BTS_SW_Rollback_Reject_triggered_by_WebEM
  [Teardown]  Configuration Postcondition

[1][1.0] Automated_SiSo_SWM_Simultaneous_RU_SW_Activate_triggered_by_WebEM
  [Setup]  Configuration Precondition  CN=REF_10_16_UTESRANSISO901_DEFAULT  N=1
  Execute Test In Loop  TC__SiSo_SWM_Simultaneous_RU_SW_Activate_triggered_by_WebEM
  [Teardown]  Configuration Postcondition

[1][1.0] Automated_SiSo_SWM_Sequential_RU_SW_Activate_triggered_by_WebEM
  [Setup]  Configuration Precondition  CN=REF_10_16_UTESRANSISO901_DEFAULT  N=1
  Execute Test In Loop  TC__SiSo_SWM_Sequential_RU_SW_Activate_triggered_by_WebEM
  [Teardown]  Configuration Postcondition
