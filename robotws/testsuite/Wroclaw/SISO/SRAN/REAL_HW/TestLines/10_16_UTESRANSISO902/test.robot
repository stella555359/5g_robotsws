*** Settings ***

Documentation
...  author: mateusz.kawka@nokia.com
...  maintainer: mateusz.kawka@nokia.com

Resource    ../../Resources/Setup/setup_and_teardown.robot
Resource    ../../TestCases/FM/FM_Fault_Signature_FID_1901.robot
Resource    ../../TestCases/PM/SiSo_PM_Radio_Module_Fan_Speed_Counters_Monitoring.robot
Resource    ../../TestCases/PM/SiSo_PM_Radio_Module_Thermal_Monitoring_Internal_NAHKA_Counters.robot
Resource    ../../TestCases/PM/SiSo_PM_Cabinet_Fan_Speed_Counters.robot

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
#${CUSTOM_MPLANE_MODE_PRIMARY_NODE_IP}=    10.42.24.137
${CUSTOM_MPLANE_MODE_PRIMARY_NODE_IP}=    10.42.24.122
${CUSTOM_SWITCH_PERFORM_SNAPSHOT}=            None      # possible settings : Failed, Always, None
${CUSTOM_SWITCH_PERFORM_HW_SETUP}=            False     # to disable hardware reconfiguration ( PDU and Optical part ) set value False
${SKIP_TRUCK_ROLL}    ${True}
@{additional_common_fault_list}=
...  faultId=2403
...  faultId=6450
...  faultId=134
...  faultId=4478
...  faultId=1868
...  faultId=10
...  faultId=1815
...  faultId=4720
&{CUSTOM_ADDITIONAL_ALLOWED_FAULTS}=   common=@{additional_common_fault_list}
${CHECK_SWCONFIG}  ${False}

#&{CUSTOM_PDU_CONFIG}=
#...  L1252002710=EPC,8221-1,10.44.167.50,11
#...  L1202703520=EPC,8221-1,10.44.167.50,12

*** Test Cases ***
[1][1.0] Automated_SiSo_FM_1901
  [Setup]  Run Keywords
  ...  Configuration Precondition  CN=live
  ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}   L1253904895
  TC__FM_Fault_Signature_FID_1901
  [Teardown]  Configuration Postcondition
#
#[1][1.0] Automated_SiSo_PM_Radio_Module_Fan_Speed_Counters_Monitoring
#  [Setup]  Run Keywords
#  ...  Configuration Precondition  CN=live
#  ...  AND  Set Test Variable  ${INTERVAL}  15
#  ...  AND  Set Test Variable  &{RMOD_FAN_DICT}  BL2244D50Y4=2
#  TC__SiSo_PM_Radio_Module_Fan_Speed_Counters_Monitoring
#  [Teardown]  Configuration Postcondition

#[1][1.0] Automated_SiSo_PM_Radio_Module_Thermal_Monitoring_Internal_NAHKA_Counters
#  [Setup]  Run Keywords
#  ...  Configuration Precondition  CN=live
#  ...  AND  Set Test Variable  ${MTSBTSRMODTEMPERATURE_INTERVAL}  15
#  ...  AND  Set Test Variable  ${RMOD_SERIAL_NUMBER}  L1181207093
#  TC__SiSo_PM_Radio_Module_Thermal_Monitoring_Internal_NAHKA_Counters
#  [Teardown]  Configuration Postcondition
#
#[1][1.0] Automated_SiSo_PM_Cabinet_Fan_Speed_Counters
#  [Setup]  Run Keywords
#  ...  Configuration Precondition  CN=live
#  ...  AND  Set Test Variable  ${INTERVAL}  15
#  ...  AND  Set Test Variable  ${CABINET_TYPE}  AMIA
#  TC__SiSo_PM_Cabinet_Fan_Speed_Counters
#  [Teardown]  Configuration Postcondition
