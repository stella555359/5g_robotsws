*** Settings ***

Documentation
...  author: malgorzata.piecyk-celuch@nokia.com
...  maintainer: malgorzata.piecyk-celuch@nokia.com

Resource    ../../Resources/Setup/setup_and_teardown.robot
Resource    ../../TestCases/FM/SiSo_FM_SMOD_Voltage_Alarms_Check.robot

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
${CUSTOM_MPLANE_MODE_PRIMARY_NODE_IP}=    10.42.174.208
${CUSTOM_SWITCH_PERFORM_SNAPSHOT}=            None      # possible settings : Failed, Always, None
${CUSTOM_SWITCH_PERFORM_HW_SETUP}=            False     # to disable hardware reconfiguration ( PDU and Optical part ) set value False
${SKIP_TRUCK_ROLL}    ${False}
@{additional_common_fault_list}=
...  faultId=2403
...  faultId=6450
...  faultId=134
...  faultId=4478
@{tc_additional_common_fault_list}=
...  faultId=4468, severity=Major
&{CUSTOM_ADDITIONAL_ALLOWED_FAULTS}=
...  common=@{additional_common_fault_list}

${CHECK_SWCONFIG}  ${False}

*** Test Cases ***
[1]Automated__SiSo_FM_SMOD_Voltage_Alarms_Check
    [Setup]  Run Keywords
    ...  Configuration Precondition  CN=live
    ...  AND  Set Test Variable  ${SMOD_SN}  L1241503072
    ...  AND  Set Test Variable  ${LAMBDA_IP_1}  10.42.36.108
    ...  AND  Set Test Variable  ${LAMBDA_PORT_1}  7777
    ...  AND  Set Test Variable  ${SMOD_CONFIGURATION_1}  SMOD-1
    TC__SiSo_FM_SMOD_Voltage_Alarms_Check
    [Teardown]  Configuration Postcondition