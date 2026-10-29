*** Settings ***
Documentation	Suite description
...    Responsible tester: przemyslaw.sas@nokia.com

Resource    ../../Resources/Setup/setup_and_teardown.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/tc_scenarios.robot
Resource   ../../robotlte_legacy/hran_ta/SiSo_SM_RU_Primary_link_break.robot
Resource   ../../robotlte_legacy/hran_ta/SiSo_SM_RU_Secondary_link_break.robot
Resource   ../../robotlte_legacy/hran_ta/SiSo_SM_RU_Primary_link_break_without_recovery.robot

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
@{additional_common_fault_list}=
...  faultId=4459
...  faultId=4589

&{CUSTOM_ADDITIONAL_ALLOWED_FAULTS}=   common=@{additional_common_fault_list}

#linkbreak variables
&{duallink_tested_cablinks_1}   CABLINK-6=10.42.201.20_293   CABLINK-15=10.42.201.20_294     #AHFIB1_397
&{duallink_tested_cablinks_2}   CABLINK-7=10.42.201.20_295   CABLINK-10=10.42.201.20_296     #AHLOA1_AM6

#4685 time delay change
#${LONG_FIBER_AHFIB_K9182400422}=  5.3.6-5.2.7
#${IP_SWITCH_AHFIB_K9182400422}=  10.42.201.12


##mandatory variables
${CUSTOM_SWITCH_PERFORM_SNAPSHOT}=     Failed      # possible settings : Failed, Always, None
${CUSTOM_SWITCH_PERFORM_HW_SETUP}=     True     # to disable hardware reconfiguration ( PDU and Optical part ) set value False
${SKIP_TRUCK_ROLL}=   True       # to disable Truck And Roll feature set this flag to False

${CELLS_YAML_PATH}=                 /home/ute/testline_configuration/10_16_UTESRANSISO132/cells.yaml
${UTE_UE_CONFIG}=                   /home/ute/testline_configuration/10_16_UTESRANSISO132/ute_ue_config.yml

*** Test Cases ***
[1][1.0] Automated_SiSo_SM_RU_Primary_link_break
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO132_DEFAULT  N=3
    ...  AND  Set Test Variable  ${TESTED_CABLINKS_OS_PORT}  &{duallink_tested_cablinks_2}     #AHLOA_AM6
#    ...  AND  Set Test Variable   ${SISO_L3_CALL}  ${TRUE}
    TC_SiSo_SM_RU_Primary_link_break
  [Teardown]  Configuration Postcondition

[1][1.0] Automated_SiSo_SM_RU_Secondary_link_break
    [Setup]  Run Keywords
   ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO132_DEFAULT  N=3
   ...  AND  Set Test Variable   ${TESTED_CABLINKS_OS_PORT}   &{duallink_tested_cablinks_2}     #AHLOA_AM6
#   ...  AND  Set Test Variable   ${SISO_L3_CALL}  ${TRUE}
    TC_SiSo_SM_RU_Secondary_link_break
  [Teardown]  Configuration Postcondition

[1][1.0] Automated_SiSo_SM_RU_Primary_link_break_without_recovery
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO132_DEFAULT  N=3
    ...  AND  Set Test Variable   ${TESTED_CABLINKS_OS_PORT}   &{duallink_tested_cablinks_2}     #AHLOA_AM6
#    ...  AND  Set Test Variable   ${SISO_L3_CALL}  ${TRUE}
    TC_SiSo_SM_RU_Primary_link_break_without_recovery
  [Teardown]  Configuration Postcondition

[2][1.0] Automated_SiSo_SM_RU_Primary_link_break
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO132_DEFAULT  N=3
    ...  AND  Set Test Variable   ${TESTED_CABLINKS_OS_PORT}   &{duallink_tested_cablinks_1}     #AHFIB_397
#    ...  AND  Set Test Variable   ${SISO_L3_CALL}  ${TRUE}
    TC_SiSo_SM_RU_Primary_link_break
  [Teardown]  Configuration Postcondition

[2][1.0] Automated_SiSo_SM_RU_Secondary_link_break
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO132_DEFAULT  N=3
    ...  AND  Set Test Variable   ${TESTED_CABLINKS_OS_PORT}   &{duallink_tested_cablinks_1}     #AHFIB_397
#    ...  AND  Set Test Variable   ${SISO_L3_CALL}  ${TRUE}
    TC_SiSo_SM_RU_Secondary_link_break
  [Teardown]  Configuration Postcondition

[2][1.0] Automated_SiSo_SM_RU_Primary_link_break_without_recovery
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO132_DEFAULT  N=3
    ...  AND  Set Test Variable   ${TESTED_CABLINKS_OS_PORT}   &{duallink_tested_cablinks_1}     #AHFIB_397
#    ...  AND  Set Test Variable   ${SISO_L3_CALL}  ${TRUE}
    TC_SiSo_SM_RU_Primary_link_break_without_recovery
  [Teardown]  Configuration Postcondition
