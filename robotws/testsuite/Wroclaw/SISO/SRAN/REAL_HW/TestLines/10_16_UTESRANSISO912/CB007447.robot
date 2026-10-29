*** Settings ***
Documentation	Suite description
...    Responsible tester: przemyslaw.kempa@nokia.com

Resource    ../../Resources/Setup/setup_and_teardown.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/tc_scenarios.robot

Resource   ../../robotlte_legacy/hran_ta/SiSo_SM_RU_Primary_link_break.robot
#Resource   ../../robotlte_legacy/hran_ta/SiSo_SM_RU_Primary_link_break_in_chaining.robot
Resource   ../../robotlte_legacy/hran_ta/SiSo_SM_RU_Secondary_link_break.robot
#Resource   ../../robotlte_legacy/hran_ta/SiSo_SM_RU_Secondary_link_break_in_chaining.robot
#Resource   ../../robotlte_legacy/hran_ta/SiSo_SM_RU_Primary_link_break_without_recovery.robot

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
@{additional_common_fault_list}
#...  faultId=2403
#...  faultId=1898
#...  faultId=4261
#...  faultId=4003

&{CUSTOM_ADDITIONAL_ALLOWED_FAULTS}   common=@{additional_common_fault_list}

#&{fullLTE2link}        HW_ID=fullLTE2link  RF=K9182544323|BL2339N49QC
&{duallink_tested_cablinks}   CABLINK-4=10.42.201.20_54  CABLINK-5=10.42.201.20_55

${CUSTOM_SWITCH_PERFORM_SNAPSHOT}     Failed      # possible settings : Failed, Always, None
${CUSTOM_SWITCH_PERFORM_HW_SETUP}     False     # to disable hardware reconfiguration ( PDU and Optical part ) set value False
${SKIP_TRUCK_ROLL}   ${False}       # to disable Truck And Roll feature set this flag to False


*** Test Cases ***
[PRIMARY_1][1.0] Automated_SiSo_SM_RU_Primary_link_break
    [Setup]  Run Keywords
    ...  Configuration Precondition  CN=live  AND
    ...  Set Test Variable  ${TESTED_CABLINKS_OS_PORT}  ${duallink_tested_cablinks}
    TC_SiSo_SM_RU_Primary_link_break
    [Teardown]  Configuration Postcondition

[SECOND][1.0] Automated_SiSo_SM_RU_Secondary_link_break
    [Setup]  Run Keywords
    ...  Configuration Precondition  CN=live  AND
    ...  Set Test Variable  ${TESTED_CABLINKS_OS_PORT}  ${duallink_tested_cablinks}
    TC_SiSo_SM_RU_Secondary_link_break
    [Teardown]    Configuration Postcondition

#[PRIMARY_1][1.0] SiSo_SM_RU_Primary_link_break_without_recovery
#    [Setup]  Run Keywords
#    ...  Configuration Precondition  CN=live  AND
#    ...  Set Test Variable  ${TESTED_CABLINKS_OS_PORT}  ${duallink_tested_cablinks}
#    TC_SiSo_SM_RU_Primary_link_break_without_recovery
#    [Teardown]  Configuration Postcondition
#
#[PRIMARY_1][1.0] SiSo_SM_RU_Primary_link_break_in_chaining
#    [Setup]  Run Keywords
#    ...  Configuration Precondition  CN=live  AND
#    ...  Set Test Variable  ${TESTED_CABLINKS_OS_PORT}  ${duallink_tested_cablinks}
#    TC_SiSo_SM_RU_Primary_link_break_in_chaining
#    [Teardown]  Configuration Postcondition
#
#[PRIMARY_1][1.0] SiSo_SM_RU_Secondary_link_break_in_chaining
#    [Setup]  Run Keywords
#    ...  Configuration Precondition  CN=live  AND
#    ...  Set Test Variable  ${TESTED_CABLINKS_OS_PORT}  ${duallink_tested_cablinks}
#    TC_SiSo_SM_RU_Secondary_link_break_in_chaining
#    [Teardown]  Configuration Postcondition
